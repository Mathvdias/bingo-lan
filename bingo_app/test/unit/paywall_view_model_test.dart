import 'package:bingo_app/features/paywall/paywall_analytics.dart';
import 'package:bingo_app/features/paywall/paywall_view_model.dart';
import 'package:bingo_app/features/paywall/purchases_gateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// ----------------------------------------------------------------- Fakes

class FakePurchasesGateway implements PurchasesGateway {
  List<Package> packages = const [];
  Object? fetchError;
  PurchaseOutcome purchaseOutcome = const PurchaseSuccess(isPremium: true);
  Object? purchaseError;
  bool restoreGrants = false;
  Object? restoreError;

  final List<Package> purchased = [];
  int fetchCalls = 0;
  int restoreCalls = 0;

  @override
  Future<List<Package>> fetchPackages() async {
    fetchCalls++;
    if (fetchError != null) throw fetchError!;
    return packages;
  }

  @override
  Future<PurchaseOutcome> purchase(Package package) async {
    purchased.add(package);
    if (purchaseError != null) throw purchaseError!;
    return purchaseOutcome;
  }

  @override
  Future<bool> restore() async {
    restoreCalls++;
    if (restoreError != null) throw restoreError!;
    return restoreGrants;
  }
}

class FakePaywallAnalytics implements PaywallAnalytics {
  final List<String> events = [];

  @override
  void paywallViewed(String source) => events.add('view:$source');

  @override
  void purchaseIntent(String productId) => events.add('intent:$productId');

  @override
  void purchased(Package package) =>
      events.add('purchase:${package.storeProduct.identifier}');

  @override
  void restored(String result) => events.add('restore:$result');
}

const _context = PresentedOfferingContext('default', null, null);

Package _package(
  String id,
  PackageType type,
  String productId,
  double price, {
  String currency = 'BRL',
}) {
  return Package(
    id,
    type,
    StoreProduct(
      productId,
      'desc',
      productId,
      price,
      'R\$ ${price.toStringAsFixed(2)}',
      currency,
    ),
    _context,
  );
}

final weekly = _package(
  '\$rc_weekly',
  PackageType.weekly,
  'weekly_subscription',
  2.99,
);
final monthly = _package(
  '\$rc_monthly',
  PackageType.monthly,
  'monthly_subscription',
  9.99,
);
final annual = _package(
  '\$rc_annual',
  PackageType.annual,
  'annual_subscription',
  29.99,
);
final lifetime = _package(
  '\$rc_lifetime',
  PackageType.lifetime,
  'lifetime_purchase',
  49.99,
);

// ----------------------------------------------------------------- Tests

void main() {
  late FakePurchasesGateway gateway;
  late FakePaywallAnalytics analytics;
  late PaywallViewModel vm;

  setUp(() {
    gateway = FakePurchasesGateway();
    analytics = FakePaywallAnalytics();
    vm = PaywallViewModel(gateway: gateway, analytics: analytics);
  });

  tearDown(() => vm.dispose());

  group('PaywallViewModel.start/load', () {
    test('começa em loading e registra paywall_view com a origem', () async {
      expect(vm.state, PaywallState.loading);
      gateway.packages = [weekly, annual];

      await vm.start('lobby');

      expect(analytics.events.first, 'view:lobby');
      expect(vm.state, PaywallState.ready);
    });

    test('ready: expõe os pacotes e pré-seleciona o anual', () async {
      gateway.packages = [weekly, annual, lifetime];

      await vm.load();

      expect(vm.state, PaywallState.ready);
      expect(vm.packages, [weekly, annual, lifetime]);
      expect(vm.selectedPackage, annual);
      expect(vm.isBusy, isFalse);
    });

    test('ready sem anual: seleciona o primeiro pacote', () async {
      gateway.packages = [monthly, lifetime];

      await vm.load();

      expect(vm.selectedPackage, monthly);
    });

    test('empty: offering sem pacotes', () async {
      gateway.packages = const [];

      await vm.load();

      expect(vm.state, PaywallState.empty);
      expect(vm.selectedPackage, isNull);
      expect(vm.error, isNull);
    });

    test('error: falha de rede vira estado error com loadFailed', () async {
      gateway.fetchError = StateError('offline');

      await vm.load();

      expect(vm.state, PaywallState.error);
      expect(vm.error, PaywallError.loadFailed);
      expect(vm.packages, isEmpty);
    });

    test('retry após erro recarrega e fica ready', () async {
      gateway.fetchError = StateError('offline');
      await vm.load();
      expect(vm.state, PaywallState.error);

      gateway.fetchError = null;
      gateway.packages = [annual];
      await vm.load();

      expect(vm.state, PaywallState.ready);
      expect(gateway.fetchCalls, 2);
    });

    test('notifica listeners a cada mudança de estado', () async {
      gateway.packages = [annual];
      var notifications = 0;
      vm.addListener(() => notifications++);

      await vm.load();

      // loading -> ready
      expect(notifications, 2);
    });
  });

  group('PaywallViewModel.selectPackage', () {
    test('troca a seleção e notifica', () async {
      gateway.packages = [weekly, annual];
      await vm.load();
      var notifications = 0;
      vm.addListener(() => notifications++);

      vm.selectPackage(weekly);

      expect(vm.selectedPackage, weekly);
      expect(notifications, 1);
    });

    test('selecionar o mesmo pacote não notifica', () async {
      gateway.packages = [weekly, annual];
      await vm.load();
      var notifications = 0;
      vm.addListener(() => notifications++);

      vm.selectPackage(annual);

      expect(notifications, 0);
    });
  });

  group('PaywallViewModel.purchase', () {
    test('sucesso: passa por purchasing, retorna true e rastreia funil',
        () async {
      gateway.packages = [weekly, annual];
      await vm.load();
      final states = <PaywallState>[];
      vm.addListener(() => states.add(vm.state));

      final granted = await vm.purchase();

      expect(granted, isTrue);
      expect(gateway.purchased, [annual]);
      expect(states, [PaywallState.purchasing, PaywallState.ready]);
      expect(vm.error, isNull);
      expect(
        analytics.events,
        containsAllInOrder([
          'intent:annual_subscription',
          'purchase:annual_subscription',
        ]),
      );
    });

    test('cancelada: volta a ready sem erro e não rastreia purchase',
        () async {
      gateway.packages = [annual];
      gateway.purchaseOutcome = const PurchaseCancelled();
      await vm.load();

      final granted = await vm.purchase();

      expect(granted, isFalse);
      expect(vm.state, PaywallState.ready);
      expect(vm.error, isNull);
      expect(analytics.events, contains('intent:annual_subscription'));
      expect(analytics.events.where((e) => e.startsWith('purchase:')), isEmpty);
    });

    test('falha da loja: erro purchaseFailed, estado ready', () async {
      gateway.packages = [annual];
      gateway.purchaseOutcome = const PurchaseFailure('store down');
      await vm.load();

      final granted = await vm.purchase();

      expect(granted, isFalse);
      expect(vm.state, PaywallState.ready);
      expect(vm.error, PaywallError.purchaseFailed);
    });

    test('exceção inesperada: erro purchaseFailed, estado ready', () async {
      gateway.packages = [annual];
      gateway.purchaseError = Exception('boom');
      await vm.load();

      final granted = await vm.purchase();

      expect(granted, isFalse);
      expect(vm.state, PaywallState.ready);
      expect(vm.error, PaywallError.purchaseFailed);
    });

    test('sucesso sem entitlement ativo é tratado como falha', () async {
      gateway.packages = [annual];
      gateway.purchaseOutcome = const PurchaseSuccess(isPremium: false);
      await vm.load();

      final granted = await vm.purchase();

      expect(granted, isFalse);
      expect(vm.error, PaywallError.purchaseFailed);
    });

    test('sem pacote selecionado não chama a loja', () async {
      gateway.packages = const [];
      await vm.load();

      final granted = await vm.purchase();

      expect(granted, isFalse);
      expect(gateway.purchased, isEmpty);
    });

    test('consumeError devolve o erro uma única vez', () async {
      gateway.packages = [annual];
      gateway.purchaseOutcome = const PurchaseFailure();
      await vm.load();
      await vm.purchase();

      expect(vm.consumeError(), PaywallError.purchaseFailed);
      expect(vm.consumeError(), isNull);
      expect(vm.error, isNull);
    });
  });

  group('PaywallViewModel.restore', () {
    test('concede premium: retorna true e rastreia restore:granted',
        () async {
      gateway.packages = [annual];
      gateway.restoreGrants = true;
      await vm.load();

      final granted = await vm.restore();

      expect(granted, isTrue);
      expect(vm.state, PaywallState.ready);
      expect(vm.error, isNull);
      expect(analytics.events, contains('restore:granted'));
    });

    test('nada para restaurar: erro restoreNothing, rastreia restore:none',
        () async {
      gateway.packages = [annual];
      gateway.restoreGrants = false;
      await vm.load();

      final granted = await vm.restore();

      expect(granted, isFalse);
      expect(vm.state, PaywallState.ready);
      expect(vm.error, PaywallError.restoreNothing);
      expect(analytics.events, contains('restore:none'));
    });

    test('falha: erro restoreFailed, rastreia restore:error', () async {
      gateway.packages = [annual];
      gateway.restoreError = Exception('offline');
      await vm.load();

      final granted = await vm.restore();

      expect(granted, isFalse);
      expect(vm.error, PaywallError.restoreFailed);
      expect(analytics.events, contains('restore:error'));
    });

    test('restaurar a partir do estado empty volta para empty', () async {
      gateway.packages = const [];
      gateway.restoreGrants = false;
      await vm.load();

      await vm.restore();

      expect(vm.state, PaywallState.empty);
    });
  });

  group('Savings', () {
    test('anual vs semanal x52', () {
      final percent = PaywallViewModel.computeSavingsPercent(
        annualPrice: 29.99,
        weeklyPrice: 2.99,
      );
      // 2.99 * 52 = 155.48 → economia de 80.7% → 80 (floor)
      expect(percent, 80);
    });

    test('anual vs mensal x12 quando não há semanal', () {
      final percent = PaywallViewModel.computeSavingsPercent(
        annualPrice: 29.99,
        monthlyPrice: 9.99,
      );
      // 9.99 * 12 = 119.88 → economia de 74.98% → 74 (floor)
      expect(percent, 74);
    });

    test('prefere o semanal quando ambos existem', () {
      final percent = PaywallViewModel.computeSavingsPercent(
        annualPrice: 50,
        weeklyPrice: 2, // 104/ano → 51%
        monthlyPrice: 5, // 60/ano → 16%
      );
      expect(percent, 51);
    });

    test('null sem base de comparação', () {
      expect(
        PaywallViewModel.computeSavingsPercent(annualPrice: 29.99),
        isNull,
      );
    });

    test('null quando o anual não é mais barato', () {
      expect(
        PaywallViewModel.computeSavingsPercent(
          annualPrice: 200,
          weeklyPrice: 1,
        ),
        isNull,
      );
      expect(
        PaywallViewModel.computeSavingsPercent(
          annualPrice: 52,
          weeklyPrice: 1,
        ),
        isNull,
      );
    });

    test('null para preços inválidos', () {
      expect(
        PaywallViewModel.computeSavingsPercent(annualPrice: 0, weeklyPrice: 1),
        isNull,
      );
      expect(
        PaywallViewModel.computeSavingsPercent(annualPrice: 10, weeklyPrice: 0),
        isNull,
      );
    });

    test('savingsPercentFor usa os pacotes carregados', () async {
      gateway.packages = [weekly, annual, lifetime];
      await vm.load();

      expect(vm.savingsPercentFor(annual), 80);
      expect(vm.savingsPercentFor(weekly), isNull);
      expect(vm.savingsPercentFor(lifetime), isNull);
    });

    test('savingsPercentFor ignora moedas diferentes', () async {
      final weeklyUsd = _package(
        '\$rc_weekly',
        PackageType.weekly,
        'weekly_subscription',
        2.99,
        currency: 'USD',
      );
      gateway.packages = [weeklyUsd, annual];
      await vm.load();

      expect(vm.savingsPercentFor(annual), isNull);
    });

    test('savingsPercentFor cai para o mensal (Test Store)', () async {
      gateway.packages = [monthly, annual, lifetime];
      await vm.load();

      expect(vm.savingsPercentFor(annual), 74);
    });
  });
}
