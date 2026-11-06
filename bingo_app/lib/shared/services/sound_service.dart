import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Efeitos sonoros do jogo. O nome do valor é o nome do arquivo em
/// `assets/audio/<name>.wav`.
enum BingoSfx {
  /// Toque genérico de botão.
  button,

  /// Marcou uma casa da cartela.
  mark,

  /// Desmarcou uma casa.
  unmark,

  /// Saiu um número no globo.
  draw,

  /// Jogador cantou bingo.
  bingo,

  /// Vitória confirmada.
  win,
}

/// Toca um efeito sonoro. Existe para que os testes substituam o
/// [AudioPlayer] real, que depende de canais de plataforma.
abstract class SfxPlayer {
  /// Toca [asset] (caminho relativo a `assets/`) em [volume] de 0 a 1.
  Future<void> play(String asset, double volume);

  /// Libera os recursos nativos.
  Future<void> dispose();
}

/// Implementação real: um pequeno pool de players usado em rodízio, para que
/// dois sons curtos possam se sobrepor.
///
/// Usa `lowLatency` (SoundPool no Android), **medido**: numa sonda rodando no
/// aparelho, `lowLatency` produz um AudioTrack por efeito e o modo padrão
/// `mediaPlayer` não produz nenhum — fica mudo sem lançar erro. A intuição
/// aqui é traiçoeira, então a escolha é por medição e não por reputação.
///
/// Se mesmo assim o `lowLatency` lançar, cai para o modo padrão e não tenta de
/// novo: um pouco de latência é melhor que silêncio.
class AudioPlayersSfxPlayer implements SfxPlayer {
  AudioPlayersSfxPlayer({int poolSize = 3})
    : _players = List<AudioPlayer>.generate(
        poolSize,
        (_) => AudioPlayer()..setReleaseMode(ReleaseMode.stop),
      );

  final List<AudioPlayer> _players;
  int _next = 0;
  bool _lowLatency = true;

  @override
  Future<void> play(String asset, double volume) async {
    final player = _players[_next];
    _next = (_next + 1) % _players.length;

    if (_lowLatency) {
      try {
        await player.play(
          AssetSource(asset),
          volume: volume,
          mode: PlayerMode.lowLatency,
        );
        return;
      } catch (e) {
        _lowLatency = false;
        log('SoundService: lowLatency falhou, usando o modo padrão: $e');
      }
    }

    await player.play(AssetSource(asset), volume: volume);
  }

  @override
  Future<void> dispose() async {
    for (final player in _players) {
      await player.dispose();
    }
  }
}

/// Som do app: liga/desliga, volume e disparo dos efeitos.
///
/// Segue o padrão dos demais serviços do projeto (estático, com
/// [ValueNotifier] para a UI observar). As preferências ficam em
/// `SharedPreferences` e sobrevivem ao fechamento do app.
///
/// Nenhum método propaga exceção: se o áudio falhar — asset ausente, sem canal
/// de plataforma, dispositivo mudo — o jogo segue em silêncio.
class SoundService {
  SoundService._();

  static const String _enabledKey = 'sound_enabled';
  static const String _volumeKey = 'sound_volume';

  /// Volume inicial. Alto o bastante para ser notado, baixo o bastante para
  /// não assustar quem abre o app pela primeira vez no transporte público.
  static const double defaultVolume = 0.7;

  /// Som ligado. Observado pela UI (`ValueListenableBuilder`).
  static final ValueNotifier<bool> enabled = ValueNotifier<bool>(true);

  /// Volume dos efeitos, de 0 a 1.
  static final ValueNotifier<double> volume = ValueNotifier<double>(
    defaultVolume,
  );

  static SfxPlayer? _player;
  static bool _initialized = false;

  /// `true` depois de [initialize].
  static bool get isInitialized => _initialized;

  /// Carrega as preferências salvas e prepara o player.
  ///
  /// [player] e [prefs] existem para os testes; em produção ficam nulos.
  /// Nunca lança: falha aqui apenas deixa o app mudo.
  static Future<void> initialize({SfxPlayer? player, SharedPreferences? prefs}) async {
    if (_initialized) return;
    _initialized = true;

    try {
      final store = prefs ?? await SharedPreferences.getInstance();
      enabled.value = store.getBool(_enabledKey) ?? true;
      volume.value = (store.getDouble(_volumeKey) ?? defaultVolume)
          .clamp(0.0, 1.0)
          .toDouble();
    } catch (e) {
      log('SoundService: falha ao ler preferências: $e');
    }

    // Em blocos separados de propósito. Antes os dois dividiam um `try`: se o
    // contexto de áudio falhasse, o player nunca era criado e o app ficava
    // mudo para sempre — sem erro visível, porque o serviço engole falhas.
    // O contexto é um ajuste fino; o player é o serviço.
    if (player == null) {
      try {
        await _applyGameAudioContext();
      } catch (e, s) {
        _report(e, s, 'sound_audio_context');
      }
    }

    try {
      _player = player ?? AudioPlayersSfxPlayer();
    } catch (e, s) {
      _report(e, s, 'sound_player_create');
    }
  }

  /// Chamado em toda falha de áudio. O `main` liga isto ao Crashlytics para
  /// que silêncio em aparelho de usuário vire dado, e não suposição: o
  /// serviço engole exceções por projeto, e sem isto ninguém fica sabendo.
  static void Function(Object error, StackTrace stack, String reason)? onError;

  static void _report(Object e, StackTrace s, String reason) {
    log('SoundService [$reason]: $e');
    try {
      onError?.call(e, s, reason);
    } catch (_) {
      // Telemetria nunca derruba o áudio.
    }
  }

  /// Contexto de áudio de efeito de jogo, não de música.
  ///
  /// O padrão do audioplayers é `AndroidAudioFocus.gain`, pensado para um
  /// player de música: cada `play` toma o foco e o som anterior recebe
  /// `AUDIOFOCUS_LOSS`. Com efeitos curtos isso aparece como o sino do
  /// sorteio (750 ms) sendo cortado quando o jogador marca uma casa logo em
  /// seguida — e também como o Bingo calando o Spotify de quem joga ouvindo
  /// música. `none` resolve os dois.
  ///
  /// No iOS, `ambient` é a categoria equivalente: mistura com outros apps e
  /// respeita a chavinha de silencioso.
  static Future<void> _applyGameAudioContext() async {
    await AudioPlayer.global.setAudioContext(
      AudioContext(
        // Só o foco muda em relação ao padrão do audioplayers. `music`/`media`
        // é a combinação mais rodada do pacote e cai com certeza no canal de
        // mídia; `game`/`sonification` é mais "correto" no papel, mas alguns
        // otimizadores de jogo de fabricante mexem nesse roteamento, e não há
        // como testar isso daqui.
        android: const AudioContextAndroid(
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
      ),
    );
  }

  /// Toca [sfx] se o som estiver ligado. Dispara e esquece: quem chama não
  /// precisa esperar, e um erro de áudio nunca interrompe a jogada.
  static void play(BingoSfx sfx) {
    if (!enabled.value || volume.value <= 0) return;
    final player = _player;
    if (player == null) return;

    unawaited(
      player
          .play('audio/${sfx.name}.wav', volume.value)
          .catchError((Object e, StackTrace s) => _report(e, s, 'sound_play')),
    );
  }

  /// Liga ou desliga o som e persiste a escolha.
  static Future<void> setEnabled(bool value) async {
    enabled.value = value;
    await _persist((store) => store.setBool(_enabledKey, value));
  }

  /// Ajusta o volume (0 a 1) e persiste.
  static Future<void> setVolume(double value) async {
    final double clamped = value.clamp(0.0, 1.0).toDouble();
    volume.value = clamped;
    await _persist((store) => store.setDouble(_volumeKey, clamped));
  }

  static Future<void> _persist(
    Future<void> Function(SharedPreferences) write,
  ) async {
    try {
      await write(await SharedPreferences.getInstance());
    } catch (e, s) {
      _report(e, s, 'sound_prefs_write');
    }
  }

  /// Só para testes: devolve o serviço ao estado inicial.
  @visibleForTesting
  static Future<void> resetForTest() async {
    await _player?.dispose();
    _player = null;
    _initialized = false;
    enabled.value = true;
    volume.value = defaultVolume;
  }
}
