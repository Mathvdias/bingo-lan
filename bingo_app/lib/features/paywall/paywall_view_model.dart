import 'package:bingo_app/shared/services/subscription_service.dart';
import 'package:bingo_app/shared/view_models/base_view_model.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:developer';

class PaywallViewModel extends BaseViewModel {
  Offerings? _offerings;
  Offerings? get offerings => _offerings;

  Package? _selectedPackage;
  Package? get selectedPackage => _selectedPackage;

  bool _isPro = false;
  bool get isPro => _isPro;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  PaywallViewModel() {
    _init();
  }

  Future<void> _init() async {
    setLoading(true);
    await _checkSubscriptionStatus();
    await fetchOfferings();
    setLoading(false);
  }

  /// Fetch available offerings from RevenueCat
  Future<void> fetchOfferings() async {
    try {
      _offerings = await SubscriptionService.getOfferings();

      // Auto-select annual as default (recommended)
      if (_offerings != null && _offerings!.current != null) {
        final packages = _offerings!.current!.availablePackages;
        // Try to select annual first
        _selectedPackage = packages.firstWhere(
          (p) => p.identifier.contains('annual'),
          orElse: () => packages.isNotEmpty
              ? packages.first
              : throw Exception('No packages available'),
        );
      }

      notifyListeners();
      log('Offerings fetched successfully');
    } catch (e) {
      log('Error fetching offerings: $e');
      _errorMessage = 'Erro ao carregar planos. Tente novamente.';
      notifyListeners();
    }
  }

  /// Check current subscription status
  Future<void> _checkSubscriptionStatus() async {
    try {
      _isPro = await SubscriptionService.hasActiveSubscription();
      notifyListeners();
    } catch (e) {
      log('Error checking subscription status: $e');
    }
  }

  /// Select a package
  void selectPackage(Package package) {
    _selectedPackage = package;
    notifyListeners();
  }

  /// Purchase selected package
  Future<bool> purchase() async {
    if (_selectedPackage == null) {
      _errorMessage = 'Por favor, selecione um plano';
      notifyListeners();
      return false;
    }

    setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      final customerInfo = await SubscriptionService.purchaseProduct(
        _selectedPackage!,
      );

      if (customerInfo != null) {
        await _checkSubscriptionStatus();
        log('Purchase successful');
        return true;
      } else {
        _errorMessage = 'Compra cancelada';
        return false;
      }
    } catch (e) {
      log('Purchase error: $e');
      _errorMessage = 'Erro ao processar compra. Tente novamente.';
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Restore previous purchases
  Future<void> restore() async {
    setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      final customerInfo = await SubscriptionService.restorePurchases();

      if (customerInfo != null) {
        await _checkSubscriptionStatus();
        if (_isPro) {
          log('Purchases restored successfully');
        } else {
          _errorMessage = 'Nenhuma compra encontrada';
        }
      }
    } catch (e) {
      log('Restore error: $e');
      _errorMessage = 'Erro ao restaurar compras.';
    } finally {
      setLoading(false);
    }
  }

  /// Get price for a package
  String getPrice(Package package) {
    return package.storeProduct.priceString;
  }

  /// Get billing period description
  String getBillingPeriod(Package package) {
    final identifier = package.identifier.toLowerCase();
    if (identifier.contains('weekly')) return '/semana';
    if (identifier.contains('annual')) return '/ano';
    if (identifier.contains('lifetime')) return '';
    return '';
  }

  /// Get savings percentage (compared to weekly)
  String? getSavings(Package package) {
    final identifier = package.identifier.toLowerCase();
    if (identifier.contains('annual')) return 'Economize 50%';
    if (identifier.contains('lifetime')) return 'Melhor valor';
    return null;
  }
}
