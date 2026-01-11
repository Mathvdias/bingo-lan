import 'dart:developer';
import 'package:bingo_app/shared/view_models/base_view_model.dart';
import 'package:bingo_core/bingo_core.dart';

class PaywallViewModel extends BaseViewModel {
  final IPaymentDriver _paymentDriver;

  bool _isPro = false;
  bool get isPro => _isPro;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  PaywallViewModel({required IPaymentDriver paymentDriver})
    : _paymentDriver = paymentDriver {
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    try {
      _isPro = await _paymentDriver.isProUser;
      notifyListeners();
    } catch (e) {
      log('Error checking pro status: $e');
    }
  }

  Future<void> purchase() async {
    setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      await _paymentDriver.purchasePro();
      await _checkStatus();
      if (_isPro) {
        // Success
      }
    } catch (e) {
      log('Purchase error: $e');
      _errorMessage = 'Erro ao processar compra. Tente novamente.';
    } finally {
      setLoading(false);
    }
  }

  Future<void> restore() async {
    setLoading(true);
    try {
      await _paymentDriver.restorePurchases();
      await _checkStatus();
    } catch (e) {
      log('Restore error: $e');
      _errorMessage = 'Erro ao restaurar compras.';
    } finally {
      setLoading(false);
    }
  }
}
