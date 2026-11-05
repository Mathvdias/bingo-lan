import 'package:bingo_app/features/settings/settings_screen.dart';
import 'package:bingo_app/shared/services/sound_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/pump_app.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await SoundService.resetForTest();
  });

  tearDown(() => SoundService.resetForTest());

  group('SettingsScreen', () {
    testWidgets('mostra o interruptor de som e os créditos', (tester) async {
      await pumpApp(tester, const SettingsScreen());

      expect(find.byKey(const Key('settings_sound_switch')), findsOneWidget);
      expect(find.byKey(const Key('settings_volume_slider')), findsOneWidget);
      expect(find.byKey(const Key('settings_audio_credits')), findsOneWidget);
      expect(find.text('Efeitos sonoros'), findsOneWidget);
    });

    testWidgets('o interruptor reflete o estado do serviço', (tester) async {
      await SoundService.setEnabled(false);

      await pumpApp(tester, const SettingsScreen());

      final toggle = tester.widget<SwitchListTile>(
        find.byKey(const Key('settings_sound_switch')),
      );
      expect(toggle.value, isFalse);
    });

    testWidgets('tocar no interruptor desliga o som', (tester) async {
      await pumpApp(tester, const SettingsScreen());
      expect(SoundService.enabled.value, isTrue);

      await tester.tap(find.byKey(const Key('settings_sound_switch')));
      await tester.pumpAndSettle();

      expect(SoundService.enabled.value, isFalse);
    });

    testWidgets('volume e teste ficam inertes com o som desligado', (
      tester,
    ) async {
      await SoundService.setEnabled(false);

      await pumpApp(tester, const SettingsScreen());

      final slider = tester.widget<Slider>(
        find.byKey(const Key('settings_volume_slider')),
      );
      expect(slider.onChanged, isNull);

      final testButton = tester.widget<TextButton>(
        find.byKey(const Key('settings_sound_test')),
      );
      expect(testButton.onPressed, isNull);
    });

    testWidgets('o slider mostra o volume atual', (tester) async {
      await SoundService.setVolume(0.3);

      await pumpApp(tester, const SettingsScreen());

      final slider = tester.widget<Slider>(
        find.byKey(const Key('settings_volume_slider')),
      );
      expect(slider.value, closeTo(0.3, 0.001));
    });
  });
}
