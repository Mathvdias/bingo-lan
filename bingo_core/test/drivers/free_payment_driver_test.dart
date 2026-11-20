import 'package:bingo_core/bingo_core.dart';
import 'package:flutter_test/flutter_test.dart';

class _PaidEverythingConfig implements IConfigDriver {
  @override
  bool getBool(String key) => true;

  @override
  int getInt(String key) => 0;

  @override
  String getString(String key) => '';

  @override
  Future<void> fetchAndActivate() async {}
}

void main() {
  group('FreePaymentDriver', () {
    const driver = FreePaymentDriver();

    test('todo usuário é premium', () async {
      expect(await driver.isProUser, isTrue);
    });

    test('compra e restauração não fazem nada nem lançam', () async {
      await driver.init();
      await driver.purchasePro();
      await driver.restorePurchases();
    });

    test('libera recursos marcados como pagos no Remote Config', () async {
      final access = AccessControlService(
        config: _PaidEverythingConfig(),
        payment: driver,
      );
      expect(await access.canAccess('is_globo_paid'), isTrue);
    });
  });
}
