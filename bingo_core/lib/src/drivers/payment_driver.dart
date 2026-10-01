import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../constants/entitlements.dart';
import 'i_payment_driver.dart';

/// Leitor do estado premium via RevenueCat.
///
/// Não configura o SDK: `Purchases.configure` acontece uma única vez no app
/// (SubscriptionService). Aqui apenas consultamos o `CustomerInfo`.
class PaymentDriver implements IPaymentDriver {
  PaymentDriver();

  @override
  Future<void> init() async {
    // Intencionalmente vazio: a configuração do RevenueCat é responsabilidade
    // do app. Manter o método preserva o contrato de IPaymentDriver.
  }

  @override
  Future<bool> get isProUser async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[kPremiumEntitlementId]?.isActive ??
          false;
    } catch (e) {
      // SDK não configurado ou sem rede: trata como não premium.
      if (kDebugMode) log('PaymentDriver: falha ao ler status premium: $e');
      return false;
    }
  }

  @override
  Future<void> purchasePro() async {
    try {
      final offerings = await Purchases.getOfferings();
      final packages = offerings.current?.availablePackages ?? const [];
      if (packages.isEmpty) return;
      await Purchases.purchase(PurchaseParams.package(packages.first));
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        log('PaymentDriver: erro na compra: $e');
      }
    } catch (e) {
      log('PaymentDriver: erro na compra: $e');
    }
  }

  @override
  Future<void> restorePurchases() async {
    try {
      await Purchases.restorePurchases();
    } catch (e) {
      log('PaymentDriver: erro ao restaurar compras: $e');
    }
  }
}
