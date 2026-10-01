import 'dart:developer';

import 'package:bingo_app/shared/services/subscription_service.dart';
import 'package:bingo_core/bingo_core.dart' show kPremiumEntitlementId;
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Resultado de uma tentativa de compra.
sealed class PurchaseOutcome {
  const PurchaseOutcome();
}

/// Compra concluída. [isPremium] indica se o entitlement ficou ativo.
class PurchaseSuccess extends PurchaseOutcome {
  final bool isPremium;
  const PurchaseSuccess({required this.isPremium});
}

/// Usuário fechou a loja sem comprar. Não é erro.
class PurchaseCancelled extends PurchaseOutcome {
  const PurchaseCancelled();
}

/// Loja ou rede falharam.
class PurchaseFailure extends PurchaseOutcome {
  final String? message;
  const PurchaseFailure([this.message]);
}

/// Abstração mínima sobre a loja para o paywall ser testável sem RevenueCat.
abstract class PurchasesGateway {
  /// Pacotes do offering atual (`offerings.current`). Lança em falha de rede.
  Future<List<Package>> fetchPackages();

  /// Compra um pacote.
  Future<PurchaseOutcome> purchase(Package package);

  /// Restaura compras. Retorna `true` se o premium ficou ativo.
  Future<bool> restore();
}

/// Implementação real sobre `purchases_flutter`.
class RevenueCatPurchasesGateway implements PurchasesGateway {
  const RevenueCatPurchasesGateway();

  static bool _isPremium(CustomerInfo info) =>
      info.entitlements.all[kPremiumEntitlementId]?.isActive ?? false;

  @override
  Future<List<Package>> fetchPackages() async {
    if (!SubscriptionService.isConfigured) {
      throw StateError('RevenueCat não configurado (sem chave para o flavor).');
    }
    final offerings = await Purchases.getOfferings();
    return offerings.current?.availablePackages ?? const <Package>[];
  }

  @override
  Future<PurchaseOutcome> purchase(Package package) async {
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      SubscriptionService.applyCustomerInfo(result.customerInfo);
      return PurchaseSuccess(isPremium: _isPremium(result.customerInfo));
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        return const PurchaseCancelled();
      }
      log('RevenueCat: erro na compra (${code.name}): ${e.message}');
      return PurchaseFailure(e.message);
    } catch (e) {
      log('RevenueCat: erro inesperado na compra: $e');
      return PurchaseFailure(e.toString());
    }
  }

  @override
  Future<bool> restore() async {
    final info = await Purchases.restorePurchases();
    SubscriptionService.applyCustomerInfo(info);
    return _isPremium(info);
  }
}
