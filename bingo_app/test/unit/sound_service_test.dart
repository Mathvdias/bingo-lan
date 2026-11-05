import 'package:bingo_app/shared/services/sound_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeSfxPlayer player;

  Future<void> start({Map<String, Object> prefs = const {}}) async {
    SharedPreferences.setMockInitialValues(prefs);
    await SoundService.resetForTest();
    player = _FakeSfxPlayer();
    await SoundService.initialize(
      player: player,
      prefs: await SharedPreferences.getInstance(),
    );
  }

  tearDown(() => SoundService.resetForTest());

  group('SoundService', () {
    test('toca o asset do efeito no volume atual', () async {
      await start();

      SoundService.play(BingoSfx.draw);
      await Future<void>.delayed(Duration.zero);

      expect(player.calls, [
        ('audio/draw.wav', SoundService.defaultVolume),
      ]);
    });

    test('cada efeito aponta para o seu arquivo', () async {
      await start();

      for (final sfx in BingoSfx.values) {
        SoundService.play(sfx);
      }
      await Future<void>.delayed(Duration.zero);

      expect(
        player.calls.map((c) => c.$1),
        BingoSfx.values.map((s) => 'audio/${s.name}.wav'),
      );
    });

    test('não toca nada com o som desligado', () async {
      await start();
      await SoundService.setEnabled(false);

      SoundService.play(BingoSfx.win);
      await Future<void>.delayed(Duration.zero);

      expect(player.calls, isEmpty);
    });

    test('não toca nada com volume zero', () async {
      await start();
      await SoundService.setVolume(0);

      SoundService.play(BingoSfx.win);
      await Future<void>.delayed(Duration.zero);

      expect(player.calls, isEmpty);
    });

    test('lê as preferências salvas na inicialização', () async {
      await start(prefs: {'sound_enabled': false, 'sound_volume': 0.25});

      expect(SoundService.enabled.value, isFalse);
      expect(SoundService.volume.value, 0.25);
    });

    test('persiste as mudanças', () async {
      await start();

      await SoundService.setEnabled(false);
      await SoundService.setVolume(0.4);

      final store = await SharedPreferences.getInstance();
      expect(store.getBool('sound_enabled'), isFalse);
      expect(store.getDouble('sound_volume'), 0.4);
    });

    test('limita o volume ao intervalo de 0 a 1', () async {
      await start();

      await SoundService.setVolume(3.2);
      expect(SoundService.volume.value, 1.0);

      await SoundService.setVolume(-0.5);
      expect(SoundService.volume.value, 0.0);
    });

    test('falha do player não escapa para quem chamou', () async {
      SharedPreferences.setMockInitialValues({});
      await SoundService.resetForTest();
      await SoundService.initialize(
        player: _ThrowingSfxPlayer(),
        prefs: await SharedPreferences.getInstance(),
      );

      expect(() => SoundService.play(BingoSfx.mark), returnsNormally);
      await Future<void>.delayed(Duration.zero);
    });

    test('sem initialize, tocar é inócuo', () async {
      await SoundService.resetForTest();
      expect(() => SoundService.play(BingoSfx.mark), returnsNormally);
    });
  });
}

class _FakeSfxPlayer implements SfxPlayer {
  final List<(String, double)> calls = <(String, double)>[];

  @override
  Future<void> play(String asset, double volume) async {
    calls.add((asset, volume));
  }

  @override
  Future<void> dispose() async {}
}

class _ThrowingSfxPlayer implements SfxPlayer {
  @override
  Future<void> play(String asset, double volume) async {
    throw StateError('sem canal de plataforma');
  }

  @override
  Future<void> dispose() async {}
}
