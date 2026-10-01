import 'package:bingo_app/features/debug/debug_flags_screen.dart';
import 'package:bingo_app/features/debug/feature_flag_catalog.dart';
import 'package:bingo_app/shared/services/revenue_config_service.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_drivers.dart';
import '../helpers/pump_app.dart';

void main() {
  late FakeConfigDriver remote;
  late MemoryKeyValueStore store;
  late OverridableConfigDriver driver;

  setUp(() {
    remote = FakeConfigDriver()
      ..values.addAll({
        RevenueConfigService.keySoloModeEnabled: true,
        RevenueConfigService.keyMaxFreePlayersPathA: 10,
        RevenueConfigService.keyRevenueModel: 'paywall_host',
      });
    store = MemoryKeyValueStore();
    driver = OverridableConfigDriver(remote, store);
  });

  String sourceText(WidgetTester tester, String key) {
    final chip = find.byKey(Key('flag_source_$key'));
    return tester.widget<Text>(
      find.descendant(of: chip, matching: find.byType(Text)),
    ).data!;
  }

  /// Rola a lista até [finder] aparecer. (`scrollUntilVisible` sem alvo acha
  /// vários Scrollables: os TextFields dos campos também têm um.)
  Future<void> reveal(WidgetTester tester, Finder finder) async {
    await tester.dragUntilVisible(
      finder,
      find.byType(ListView),
      const Offset(0, -150),
    );
    await tester.pumpAndSettle();
  }

  group('DebugFlagsScreen', () {
    testWidgets('lista todas as flags do catálogo como remotas', (
      tester,
    ) async {
      await pumpApp(tester, DebugFlagsScreen(driver: driver));

      for (final flag in featureFlagCatalog) {
        await reveal(tester, find.byKey(Key('flag_tile_${flag.key}')));
        expect(find.text(flag.key), findsOneWidget);
        expect(sourceText(tester, flag.key), 'remoto');
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('ligar o switch grava override e a origem muda', (
      tester,
    ) async {
      await pumpApp(tester, DebugFlagsScreen(driver: driver));
      const key = RevenueConfigService.keySoloModeEnabled;
      await reveal(tester, find.byKey(const Key('flag_tile_$key')));

      expect(sourceText(tester, key), 'remoto');
      expect(driver.getBool(key), isTrue);

      await tester.tap(find.byKey(const Key('flag_switch_$key')));
      await tester.pumpAndSettle();

      expect(driver.overrides, {key: false});
      expect(driver.getBool(key), isFalse);
      expect(sourceText(tester, key), 'override');
      expect(find.text('Efetivo: false'), findsWidgets);
      // Persistiu no store.
      expect(store.values, {key: false});

      // Voltar ao remoto pelo botão da própria flag.
      await tester.tap(find.byKey(const Key('flag_clear_$key')));
      await tester.pumpAndSettle();
      expect(driver.overrides, isEmpty);
      expect(sourceText(tester, key), 'remoto');
      expect(driver.getBool(key), isTrue);
    });

    testWidgets('stepper do int e dropdown da string gravam override', (
      tester,
    ) async {
      await pumpApp(tester, DebugFlagsScreen(driver: driver));
      const intKey = RevenueConfigService.keyMaxFreePlayersPathA;
      const strKey = RevenueConfigService.keyRevenueModel;

      // Na ordem do catálogo (a lista só rola para baixo): string antes
      // do int.
      await reveal(tester, find.byKey(const Key('flag_dropdown_$strKey')));
      await tester.tap(find.byKey(const Key('flag_dropdown_$strKey')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ad_supported').last);
      await tester.pumpAndSettle();
      expect(driver.getString(strKey), 'ad_supported');
      expect(sourceText(tester, strKey), 'override');

      await reveal(tester, find.byKey(const Key('flag_int_plus_$intKey')));
      await tester.tap(find.byKey(const Key('flag_int_plus_$intKey')));
      await tester.pumpAndSettle();
      expect(driver.getInt(intKey), 11);
      await tester.tap(find.byKey(const Key('flag_int_minus_$intKey')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('flag_int_minus_$intKey')));
      await tester.pumpAndSettle();
      expect(driver.getInt(intKey), 9);
      expect(sourceText(tester, intKey), 'override');
    });

    testWidgets('"Limpar overrides" zera tudo e "Buscar remoto" delega', (
      tester,
    ) async {
      await driver.setOverride(RevenueConfigService.keyAdsEnabled, true);
      await driver.setOverride(RevenueConfigService.keyIsGloboPaid, true);
      await pumpApp(tester, DebugFlagsScreen(driver: driver));

      expect(
        tester
            .widget<Text>(find.byKey(const Key('debug_flags_summary')))
            .data,
        startsWith('2 override(s)'),
      );

      await tester.tap(find.byKey(const Key('debug_flags_clear_all')));
      await tester.pumpAndSettle();
      expect(driver.overrides, isEmpty);
      expect(store.values, isEmpty);
      expect(
        sourceText(tester, RevenueConfigService.keyAdsEnabled),
        'remoto',
      );

      // O SnackBar de "Overrides limpos." cobre o rodapé por 4 s; espera
      // sumir antes de tocar no outro botão.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('debug_flags_refetch')));
      await tester.pumpAndSettle();
      expect(remote.fetches, 1);
    });
  });
}
