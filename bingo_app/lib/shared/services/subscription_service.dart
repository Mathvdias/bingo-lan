import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bingo_app/core/config/env.dart';
import 'package:bingo_app/flavors/app_config.dart';
import 'package:bingo_app/shared/services/analytics_service.dart';
import 'package:bingo_core/bingo_core.dart' show kPremiumEntitlementId;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Único ponto de configuração do RevenueCat no app.
///
/// Mantém o status premium em cache ([isPremium]) atualizado pelo listener de
/// `CustomerInfo`. Gates de UI leem o cache; [refresh] força uma releitura.
class SubscriptionService {
  SubscriptionService._();

  static const String weeklyProductId = 'weekly_subscription';
  static const String annualProductId = 'annual_subscription';
  static const String lifetimeProductId = 'lifetime_purchase';

  /// Status premium em cache. `false` até o primeiro `CustomerInfo` chegar.
  static final ValueNotifier<bool> isPremium = ValueNotifier<bool>(false);

  static final _premiumStatusController = StreamController<bool>.broadcast();

  /// Stream do status premium (emite apenas quando o valor muda).
  static Stream<bool> get premiumStatusStream =>
      _premiumStatusController.stream;

  static bool _configured = false;

  static bool _openEdition = false;

  /// `true` quando o app roda sem RevenueCat (edição aberta): premium liberado.
  static bool get isOpenEdition => _openEdition;

  /// `true` após `Purchases.configure` ter sido chamado com sucesso.
  static bool get isConfigured => _configured;

  /// Configura o RevenueCat uma única vez e carrega o status inicial.
  ///
  /// Em dev com `RC_TEST_STORE_KEY` definida usa o RevenueCat Test Store.
  /// Nunca lança: falhas são logadas e o app segue como usuário free.
  static Future<void> initialize({
    required AppConfig appConfig,
    String? apiKey,
    String? userId,
  }) async {
    if (_configured) return;

    final key =
        apiKey ?? Env.revenueCatKeyFor(appConfig, isIOS: Platform.isIOS);
    if (key.isEmpty) {
      log('Edição aberta: sem chave do RevenueCat, tudo liberado.');
      _openEdition = true;
      _setPremium(true);
      return;
    }

    try {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      final configuration = PurchasesConfiguration(key);
      if (userId != null) {
        configuration.appUserID = userId;
      }
      await Purchases.configure(configuration);
      _configured = true;

      Purchases.addCustomerInfoUpdateListener(applyCustomerInfo);
      await refresh();

      if (kDebugMode) {
        final usingTestStore =
            appConfig.isDev && key == Env.revenueCatTestStoreKey;
        log(
          'RevenueCat configurado'
          '${usingTestStore ? ' (Test Store)' : ''}.',
        );
      }
    } catch (e) {
      log('RevenueCat: falha ao configurar: $e');
    }
  }

  /// Atualiza o cache a partir de um [CustomerInfo] (listener, compra, restore).
  static void applyCustomerInfo(CustomerInfo? info) {
    if (info == null) return;
    final active =
        info.entitlements.all[kPremiumEntitlementId]?.isActive ?? false;
    _setPremium(active);
  }

  static void _setPremium(bool value) {
    if (isPremium.value == value) return;
    isPremium.value = value;
    _premiumStatusController.add(value);
    AnalyticsService.setSubscriptionStatus(value);
  }

  /// Releitura explícita do `CustomerInfo`. Retorna o status premium atual.
  static Future<bool> refresh() async {
    if (!_configured) return isPremium.value;
    try {
      final info = await Purchases.getCustomerInfo();
      applyCustomerInfo(info);
    } catch (e) {
      log('RevenueCat: falha ao ler CustomerInfo: $e');
    }
    return isPremium.value;
  }

  /// Identifica o usuário (chamar após autenticação, se houver).
  static Future<void> setUserId(String userId) async {
    if (!_configured) return;
    try {
      final result = await Purchases.logIn(userId);
      applyCustomerInfo(result.customerInfo);
    } catch (e) {
      log('RevenueCat: falha no logIn: $e');
    }
  }

  /// Offerings atuais ou `null` em caso de erro.
  static Future<Offerings?> getOfferings() async {
    if (!_configured) return null;
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      log('RevenueCat: falha ao buscar offerings: $e');
      return null;
    }
  }

  /// Compra um pacote. Retorna `null` se cancelado ou em erro.
  static Future<CustomerInfo?> purchaseProduct(Package package) async {
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      applyCustomerInfo(result.customerInfo);
      return result.customerInfo;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        log('RevenueCat: erro na compra: $e');
      }
      return null;
    } catch (e) {
      log('RevenueCat: erro na compra: $e');
      return null;
    }
  }

  /// Restaura compras. Retorna `null` em erro.
  static Future<CustomerInfo?> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      applyCustomerInfo(info);
      return info;
    } catch (e) {
      log('RevenueCat: erro ao restaurar: $e');
      return null;
    }
  }

  /// Encerra a sessão do usuário identificado.
  static Future<void> signOut() async {
    if (!_configured) return;
    try {
      final info = await Purchases.logOut();
      applyCustomerInfo(info);
    } catch (e) {
      log('RevenueCat: falha no logOut: $e');
    }
  }
}
