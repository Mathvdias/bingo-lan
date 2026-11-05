import 'package:bingo_app/shared/services/sound_service.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/pump_app.dart';

void main() {
  late _FakeSfxPlayer player;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await SoundService.resetForTest();
    player = _FakeSfxPlayer();
    await SoundService.initialize(
      player: player,
      prefs: await SharedPreferences.getInstance(),
    );
  });

  tearDown(() => SoundService.resetForTest());

  group('BingoButton e som', () {
    testWidgets('toca o clique genérico por padrão', (tester) async {
      await pumpApp(
        tester,
        BingoButton(label: 'Jogar', onPressed: () {}),
      );

      await tester.tap(find.byType(BingoButton));
      await tester.pumpAndSettle();

      expect(player.assets, ['audio/button.wav']);
    });

    // Regressão: sortear e cantar bingo já têm som próprio. Com o clique
    // genérico ligado, os dois tocavam no mesmo instante — um clique de 50 ms
    // por cima de um sino de 750 ms.
    testWidgets('não toca o clique quando a ação tem som próprio', (
      tester,
    ) async {
      await pumpApp(
        tester,
        BingoButton(label: 'Sortear', tapSound: false, onPressed: () {}),
      );

      await tester.tap(find.byType(BingoButton));
      await tester.pumpAndSettle();

      expect(player.assets, isEmpty);
    });

    testWidgets('botão desabilitado não toca nada', (tester) async {
      await pumpApp(
        tester,
        BingoButton(label: 'Sortear', enabled: false, onPressed: () {}),
      );

      await tester.tap(find.byType(BingoButton), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(player.assets, isEmpty);
    });
  });
}

class _FakeSfxPlayer implements SfxPlayer {
  final List<String> assets = <String>[];

  @override
  Future<void> play(String asset, double volume) async => assets.add(asset);

  @override
  Future<void> dispose() async {}
}
