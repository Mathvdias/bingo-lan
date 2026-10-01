import 'package:bingo_app/core/config/env.dart';
import 'package:bingo_app/flavors/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final prod = AppConfig(
    flavor: Flavor.prod,
    appTitle: 'Bingo',
    apiBaseUrl: '',
  );
  final dev = AppConfig(
    flavor: Flavor.dev,
    appTitle: 'Bingo dev',
    apiBaseUrl: '',
  );
  final alpha = AppConfig(
    flavor: Flavor.alpha,
    appTitle: 'Bingo β',
    apiBaseUrl: '',
  );

  group('Env.revenueCatKeyFor', () {
    test('alpha usa a chave de loja mesmo com Test Store definida', () {
      // Em testes as constantes de --dart-define estão vazias: dev e alpha
      // caem na chave da plataforma (vazia), nunca lançam.
      expect(Env.revenueCatKeyFor(alpha, isIOS: false), isEmpty);
      expect(Env.revenueCatKeyFor(alpha, isIOS: true), isEmpty);
    });
  });

  group('Env.missingKeys', () {
    test('alpha exige a chave de loja como a prod (sem Test Store)', () {
      expect(
        Env.missingKeys(alpha, isIOS: false, androidKey: 'goog_x', iosKey: ''),
        isEmpty,
      );
      expect(
        Env.missingKeys(
          alpha,
          isIOS: false,
          androidKey: '',
          iosKey: '',
          testStoreKey: 'test_x',
        ),
        ['RC_ANDROID_KEY'],
        reason: 'Test Store não vale no alpha',
      );
      expect(
        Env.missingKeys(alpha, isIOS: true, androidKey: 'goog_x', iosKey: ''),
        ['RC_IOS_KEY'],
      );
    });

    test('prod Android só exige RC_ANDROID_KEY', () {
      expect(
        Env.missingKeys(prod, isIOS: false, androidKey: 'goog_x', iosKey: ''),
        isEmpty,
      );
      expect(
        Env.missingKeys(prod, isIOS: false, androidKey: '', iosKey: 'appl_x'),
        ['RC_ANDROID_KEY'],
      );
    });

    test('prod iOS só exige RC_IOS_KEY', () {
      expect(
        Env.missingKeys(prod, isIOS: true, androidKey: '', iosKey: 'appl_x'),
        isEmpty,
      );
      expect(
        Env.missingKeys(prod, isIOS: true, androidKey: 'goog_x', iosKey: ''),
        ['RC_IOS_KEY'],
      );
    });

    test('dev aceita Test Store no lugar das chaves de loja', () {
      expect(
        Env.missingKeys(
          dev,
          isIOS: false,
          androidKey: '',
          iosKey: '',
          testStoreKey: 'test_x',
        ),
        isEmpty,
      );
      expect(
        Env.missingKeys(
          dev,
          isIOS: false,
          androidKey: '',
          iosKey: '',
          testStoreKey: '',
        ),
        ['RC_ANDROID_KEY', 'RC_TEST_STORE_KEY'],
      );
    });
  });

  group('Env.validate', () {
    test('nunca lança; devolve mensagem quando falta chave', () {
      // Nos testes as constantes de --dart-define estão vazias.
      final message = Env.validate(prod, isIOS: false);
      expect(message, isNotNull);
      expect(message, contains('RC_ANDROID_KEY'));
      expect(message, isNot(contains('RC_IOS_KEY')));
    });

    test('alpha recebe a mesma mensagem de build prod', () {
      final message = Env.validate(alpha, isIOS: false);
      expect(message, contains('Build prod sem RC_ANDROID_KEY'));
    });
  });
}
