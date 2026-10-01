import 'dart:developer';

import 'package:bingo_app/features/paywall/paywall_analytics.dart';
import 'package:bingo_app/features/paywall/purchases_gateway.dart';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

enum PaywallState { loading, ready, empty, error, purchasing }

/// Erros que a tela traduz para texto localizado.
enum PaywallError { loadFailed, purchaseFailed, restoreFailed, restoreNothing }

/// Estado do paywall próprio. Sem strings: a tela localiza tudo.
class PaywallViewModel extends ChangeNotifier {
  final PurchasesGateway _gateway;
  final PaywallAnalytics? _analytics;

  PaywallViewModel({
    required PurchasesGateway gateway,
    PaywallAnalytics? analytics,
  }) : _gateway = gateway,
       _analytics = analytics;

  PaywallState _state = PaywallState.loading;
  List<Package> _packages = const [];
  Package? _selectedPackage;
  PaywallError? _error;
  PaywallState _stateBeforeAction = PaywallState.ready;

  PaywallState get state => _state;
  List<Package> get packages => _packages;
  Package? get selectedPackage => _selectedPackage;

  /// Erro pendente (one-shot). A tela chama [consumeError] ao exibir.
  PaywallError? get error => _error;

  bool get isBusy =>
      _state == PaywallState.loading || _state == PaywallState.purchasing;

  /// Abre o paywall: registra a visualização e carrega os pacotes.
  Future<void> start(String source) {
    _analytics?.paywallViewed(source);
    return load();
  }

  /// Carrega `offerings.current`. Usado também pelo "tentar de novo".
  Future<void> load() async {
    _error = null;
    _setState(PaywallState.loading);
    try {
      final packages = await _gateway.fetchPackages();
      _packages = List<Package>.unmodifiable(packages);
      _selectedPackage = _defaultSelection(_packages);
      _setState(_packages.isEmpty ? PaywallState.empty : PaywallState.ready);
    } catch (e) {
      log('Paywall: falha ao carregar pacotes: $e');
      _packages = const [];
      _selectedPackage = null;
      _error = PaywallError.loadFailed;
      _setState(PaywallState.error);
    }
  }

  void selectPackage(Package package) {
    if (_state == PaywallState.purchasing) return;
    if (_selectedPackage == package) return;
    _selectedPackage = package;
    notifyListeners();
  }

  /// Compra o pacote selecionado. Retorna `true` se o premium ficou ativo.
  Future<bool> purchase() async {
    final package = _selectedPackage;
    if (package == null || isBusy) return false;

    _analytics?.purchaseIntent(package.storeProduct.identifier);
    _beginAction();
    try {
      final outcome = await _gateway.purchase(package);
      switch (outcome) {
        case PurchaseSuccess(:final isPremium):
          if (isPremium) {
            _analytics?.purchased(package);
            _endAction();
            return true;
          }
          // Compra passou mas o entitlement não ativou: configuração errada.
          log('Paywall: compra sem entitlement premium ativo.');
          _endAction(error: PaywallError.purchaseFailed);
          return false;
        case PurchaseCancelled():
          _endAction();
          return false;
        case PurchaseFailure(:final message):
          log('Paywall: compra falhou: $message');
          _endAction(error: PaywallError.purchaseFailed);
          return false;
      }
    } catch (e) {
      log('Paywall: erro inesperado na compra: $e');
      _endAction(error: PaywallError.purchaseFailed);
      return false;
    }
  }

  /// Restaura compras. Retorna `true` se o premium ficou ativo.
  Future<bool> restore() async {
    if (_state == PaywallState.purchasing || _state == PaywallState.loading) {
      return false;
    }
    _beginAction();
    try {
      final granted = await _gateway.restore();
      _analytics?.restored(granted ? 'granted' : 'none');
      _endAction(error: granted ? null : PaywallError.restoreNothing);
      return granted;
    } catch (e) {
      log('Paywall: falha ao restaurar: $e');
      _analytics?.restored('error');
      _endAction(error: PaywallError.restoreFailed);
      return false;
    }
  }

  /// Devolve o erro pendente e o limpa sem notificar.
  PaywallError? consumeError() {
    final error = _error;
    _error = null;
    return error;
  }

  // ------------------------------------------------------------- Cálculos

  /// Percentual economizado pelo plano anual frente ao semanal (x52) ou,
  /// na ausência dele, ao mensal (x12). `null` quando não há base comparável
  /// ou quando o anual não é mais barato.
  static int? computeSavingsPercent({
    required double annualPrice,
    double? weeklyPrice,
    double? monthlyPrice,
  }) {
    double? reference;
    if (weeklyPrice != null && weeklyPrice > 0) {
      reference = weeklyPrice * 52;
    } else if (monthlyPrice != null && monthlyPrice > 0) {
      reference = monthlyPrice * 12;
    }
    if (reference == null || annualPrice <= 0 || annualPrice >= reference) {
      return null;
    }
    final percent = ((1 - annualPrice / reference) * 100).floor();
    return percent > 0 ? percent : null;
  }

  /// Economia do [package] (apenas anual) frente aos demais pacotes
  /// carregados, exigindo a mesma moeda.
  int? savingsPercentFor(Package package) {
    if (package.packageType != PackageType.annual) return null;
    final currency = package.storeProduct.currencyCode;
    final weekly = _findByType(PackageType.weekly, currency);
    final monthly = _findByType(PackageType.monthly, currency);
    return computeSavingsPercent(
      annualPrice: package.storeProduct.price,
      weeklyPrice: weekly?.storeProduct.price,
      monthlyPrice: monthly?.storeProduct.price,
    );
  }

  Package? _findByType(PackageType type, String currency) {
    for (final p in _packages) {
      if (p.packageType == type && p.storeProduct.currencyCode == currency) {
        return p;
      }
    }
    return null;
  }

  static Package? _defaultSelection(List<Package> packages) {
    if (packages.isEmpty) return null;
    for (final p in packages) {
      if (p.packageType == PackageType.annual) return p;
    }
    return packages.first;
  }

  // ------------------------------------------------------------- Estado

  void _beginAction() {
    _error = null;
    _stateBeforeAction = _state == PaywallState.loading
        ? PaywallState.ready
        : _state;
    _setState(PaywallState.purchasing);
  }

  void _endAction({PaywallError? error}) {
    _error = error;
    _setState(_stateBeforeAction);
  }

  void _setState(PaywallState value) {
    _state = value;
    notifyListeners();
  }
}
