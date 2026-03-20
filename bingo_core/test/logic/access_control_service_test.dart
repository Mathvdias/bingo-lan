import 'package:bingo_core/bingo_core.dart';
import 'package:flutter_test/flutter_test.dart';

class MockConfigDriver implements IConfigDriver {
  final Map<String, dynamic> _configs = {};

  void setMockValue(String key, dynamic value) {
    _configs[key] = value;
  }

  @override
  bool getBool(String key) => _configs[key] as bool? ?? false;

  @override
  int getInt(String key) => _configs[key] as int? ?? 0;

  @override
  String getString(String key) => _configs[key] as String? ?? '';

  @override
  Future<void> fetchAndActivate() async {}
}

class MockPaymentDriver implements IPaymentDriver {
  bool _isPro = false;

  void setProStatus(bool pro) {
    _isPro = pro;
  }

  @override
  Future<bool> get isProUser async => _isPro;

  @override
  Future<void> init() async {}

  @override
  Future<void> purchasePro() async {}

  @override
  Future<void> restorePurchases() async {}
}

void main() {
  group('AccessControlService Tests', () {
    late MockConfigDriver mockConfig;
    late MockPaymentDriver mockPayment;
    late AccessControlService service;

    setUp(() {
      mockConfig = MockConfigDriver();
      mockPayment = MockPaymentDriver();
      service = AccessControlService(config: mockConfig, payment: mockPayment);
    });

    test('canAccess returns true for free features', () async {
      mockConfig.setMockValue('is_globo_paid', false);
      expect(await service.canAccess('is_globo_paid'), true);
    });

    test(
      'canAccess returns false for paid feature when user is not pro',
      () async {
        mockConfig.setMockValue('is_globo_paid', true);
        mockPayment.setProStatus(false);
        expect(await service.canAccess('is_globo_paid'), false);
      },
    );

    test('canAccess returns true for paid feature when user is pro', () async {
      mockConfig.setMockValue('is_globo_paid', true);
      mockPayment.setProStatus(true);
      expect(await service.canAccess('is_globo_paid'), true);
    });
  });
}
