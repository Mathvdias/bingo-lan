import 'package:bingo_app/flavors/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig', () {
    test('isDev e isProd', () {
      final dev = AppConfig(
        flavor: Flavor.dev,
        appTitle: 'D',
        apiBaseUrl: 'http://localhost',
      );
      final prod = AppConfig(
        flavor: Flavor.prod,
        appTitle: 'P',
        apiBaseUrl: 'https://api.example.com',
      );
      expect(dev.isDev, isTrue);
      expect(dev.isProd, isFalse);
      expect(prod.isProd, isTrue);
      expect(prod.isDev, isFalse);
    });
  });
}
