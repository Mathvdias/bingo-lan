import 'package:bingo_app/flavors/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig', () {
    final dev = AppConfig(
      flavor: Flavor.dev,
      appTitle: 'D',
      apiBaseUrl: 'http://localhost',
    );
    final alpha = AppConfig(
      flavor: Flavor.alpha,
      appTitle: 'A',
      apiBaseUrl: 'https://api.example.com',
    );
    final prod = AppConfig(
      flavor: Flavor.prod,
      appTitle: 'P',
      apiBaseUrl: 'https://api.example.com',
    );

    test('isDev, isAlpha e isProd', () {
      expect(dev.isDev, isTrue);
      expect(dev.isAlpha, isFalse);
      expect(dev.isProd, isFalse);
      expect(alpha.isDev, isFalse);
      expect(alpha.isAlpha, isTrue);
      expect(alpha.isProd, isFalse);
      expect(prod.isProd, isTrue);
      expect(prod.isDev, isFalse);
      expect(prod.isAlpha, isFalse);
    });

    test('hasDebugTools só em dev e alpha', () {
      expect(dev.hasDebugTools, isTrue);
      expect(alpha.hasDebugTools, isTrue);
      expect(prod.hasDebugTools, isFalse);
    });
  });
}
