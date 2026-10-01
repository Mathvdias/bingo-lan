import 'package:bingo_core/bingo_core.dart';

/// Remote Config falso: tudo desligado/zero, sem Firebase.
class FakeConfigDriver implements IConfigDriver {
  final Map<String, Object> values = {};

  @override
  Future<void> fetchAndActivate() async {}

  @override
  bool getBool(String key) => values[key] as bool? ?? false;

  @override
  int getInt(String key) => values[key] as int? ?? 0;

  @override
  String getString(String key) => values[key] as String? ?? '';
}

/// Pagamentos falsos: usuário grátis, sem RevenueCat.
class FakePaymentDriver implements IPaymentDriver {
  bool pro = false;

  @override
  Future<bool> get isProUser async => pro;

  @override
  Future<void> init() async {}

  @override
  Future<void> purchasePro() async {}

  @override
  Future<void> restorePurchases() async {}
}
