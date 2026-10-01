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

  group('Env.missingKeys', () {
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
  });
}
