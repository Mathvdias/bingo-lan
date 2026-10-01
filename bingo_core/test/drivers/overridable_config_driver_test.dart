import 'package:bingo_core/bingo_core.dart';
import 'package:flutter_test/flutter_test.dart';

/// Driver remoto falso com valores fixos e contagem de fetches.
class _Remote implements IConfigDriver {
  final Map<String, Object> values;
  int fetches = 0;

  _Remote(this.values);

  @override
  Future<void> fetchAndActivate() async => fetches++;

  @override
  bool getBool(String key) => values[key] as bool? ?? false;

  @override
  int getInt(String key) => values[key] as int? ?? 0;

  @override
  String getString(String key) => values[key] as String? ?? '';
}

void main() {
  late _Remote remote;
  late MemoryKeyValueStore store;
  late OverridableConfigDriver driver;

  setUp(() {
    remote = _Remote({
      'solo_mode_enabled': true,
      'max_free_players_path_a': 10,
      'revenue_model': 'paywall_host',
    });
    store = MemoryKeyValueStore();
    driver = OverridableConfigDriver(remote, store);
  });

  group('OverridableConfigDriver', () {
    test('sem override delega ao remoto', () {
      expect(driver.getBool('solo_mode_enabled'), isTrue);
      expect(driver.getInt('max_free_players_path_a'), 10);
      expect(driver.getString('revenue_model'), 'paywall_host');
      expect(driver.sourceOf('solo_mode_enabled'), ConfigSource.remote);
      expect(driver.hasOverride('solo_mode_enabled'), isFalse);
    });

    test('override vence o remoto e marca a origem', () async {
      await driver.setOverride('solo_mode_enabled', false);
      await driver.setOverride('max_free_players_path_a', 2);
      await driver.setOverride('revenue_model', 'ad_supported');

      expect(driver.getBool('solo_mode_enabled'), isFalse);
      expect(driver.getInt('max_free_players_path_a'), 2);
      expect(driver.getString('revenue_model'), 'ad_supported');
      expect(driver.sourceOf('solo_mode_enabled'), ConfigSource.override);
      expect(driver.overrides, {
        'solo_mode_enabled': false,
        'max_free_players_path_a': 2,
        'revenue_model': 'ad_supported',
      });
    });

    test('override de tipo diferente do pedido é ignorado', () async {
      // Um String guardado numa chave lida como bool não quebra a leitura.
      await driver.setOverride('solo_mode_enabled', 'sim');
      expect(driver.getBool('solo_mode_enabled'), isTrue);
    });

    test('effective lê pelo tipo informado', () async {
      expect(
        driver.effective('max_free_players_path_a', ConfigValueType.integer),
        10,
      );
      await driver.setOverride('max_free_players_path_a', 3);
      expect(
        driver.effective('max_free_players_path_a', ConfigValueType.integer),
        3,
      );
      expect(
        driver.effective('solo_mode_enabled', ConfigValueType.boolean),
        isTrue,
      );
      expect(
        driver.effective('revenue_model', ConfigValueType.string),
        'paywall_host',
      );
    });

    test('limpar um override volta ao remoto; clearAll limpa tudo', () async {
      await driver.setOverride('solo_mode_enabled', false);
      await driver.setOverride('max_free_players_path_a', 1);

      await driver.clearOverride('solo_mode_enabled');
      expect(driver.getBool('solo_mode_enabled'), isTrue);
      expect(driver.getInt('max_free_players_path_a'), 1);

      await driver.clearAll();
      expect(driver.overrides, isEmpty);
      expect(driver.getInt('max_free_players_path_a'), 10);
      expect(store.values, isEmpty);
    });

    test('notifica a cada mudança e após fetchAndActivate', () async {
      var notifications = 0;
      driver.addListener(() => notifications++);

      await driver.setOverride('solo_mode_enabled', false);
      expect(notifications, 1);

      await driver.clearOverride('solo_mode_enabled');
      expect(notifications, 2);

      // Limpar o que não existe não notifica.
      await driver.clearOverride('solo_mode_enabled');
      await driver.clearAll();
      expect(notifications, 2);

      await driver.fetchAndActivate();
      expect(remote.fetches, 1);
      expect(notifications, 3);
    });

    test('persiste no store e recarrega em outra instância', () async {
      await driver.setOverride('solo_mode_enabled', false);
      await driver.setOverride('max_free_players_path_a', 4);
      await driver.setOverride('paywall_variant', 'b');
      expect(store.values, {
        'solo_mode_enabled': false,
        'max_free_players_path_a': 4,
        'paywall_variant': 'b',
      });

      final reloaded = OverridableConfigDriver(remote, store);
      expect(reloaded.overrides, isEmpty, reason: 'antes do load');
      await reloaded.load();
      expect(reloaded.getBool('solo_mode_enabled'), isFalse);
      expect(reloaded.getInt('max_free_players_path_a'), 4);
      expect(reloaded.getString('paywall_variant'), 'b');
    });

    test('load descarta valores de tipo não suportado', () async {
      await store.set('solo_mode_enabled', 1.5);
      await store.set('revenue_model', 'ad_supported');
      await driver.load();
      expect(driver.overrides, {'revenue_model': 'ad_supported'});
      expect(await store.keys(), {'revenue_model'});
    });

    test('setOverride rejeita tipos não suportados', () {
      expect(
        () => driver.setOverride('x', 1.5),
        throwsA(isA<ArgumentError>()),
      );
      expect(() => driver.setOverride('x', [1]), throwsA(isA<ArgumentError>()));
    });
  });
}
