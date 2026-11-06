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

/// Implementação real: **um player por efeito**, reaproveitado, e um `stop()`
/// antes de cada disparo.
///
/// As duas coisas são exigidas pelo `SoundPool`, que é o que está atrás do
/// `PlayerMode.lowLatency` no Android, e cada uma por um motivo diferente:
///
/// 1. `stop()` antes de tocar. O `SoundPool` não tem callback de fim de som —
///    só o `MediaPlayer` tem — então o `audioplayers` nunca marca o player
///    como parado: `WrappedPlayer.playing` fica `true` para sempre depois do
///    primeiro disparo, e todo `play()` seguinte bate no guarda
///    `if (!playing && !released)` e volta sem tocar nada. Resultado: cada
///    player tocava **uma vez na vida**. Era por isso que um pool de 3 rendia
///    exatamente 3 sons por abertura do app e tudo depois disso ficava mudo,
///    inclusive o botão "testar" das configurações. `stop()`, com
///    `ReleaseMode.stop`, zera o `playing` e o `streamId` sem descarregar a
///    amostra: barato, sem reler o arquivo.
///
/// 2. Um player por efeito. O `SoundPool` indexa as amostras por URL e deixa o
///    player registrado na URL antiga quando a fonte muda, então um player
///    reaproveitado entre efeitos diferentes passa a servir o `soundId` errado
///    para quem pedir o som antigo. Amarrando cada player a um único asset, a
///    fonte nunca muda e o problema não existe.
///
/// Efeitos diferentes continuam podendo se sobrepor, porque são players
/// diferentes — era o que o pool em rodízio queria garantir. O mesmo efeito
/// disparado duas vezes rápido se corta e recomeça, que é justamente o que se
/// quer no clique da cartela.
///
/// Sobre o modo: `lowLatency` é escolha **medida**: numa sonda rodando no
/// aparelho, `lowLatency` produz um AudioTrack por efeito e o modo padrão
/// `mediaPlayer` não produz nenhum — fica mudo sem lançar erro. A intuição
/// aqui é traiçoeira, então a escolha é por medição e não por reputação. Se
/// mesmo assim o `lowLatency` lançar, cai para o modo padrão e não tenta de
/// novo: um pouco de latência é melhor que silêncio.
class AudioPlayersSfxPlayer implements SfxPlayer {
  AudioPlayersSfxPlayer();

  /// Um player por asset. Criados sob demanda: o primeiro disparo de cada
  /// efeito paga a carga da amostra, os seguintes não.
  final Map<String, AudioPlayer> _players = <String, AudioPlayer>{};

  /// Fila por asset. O `stop()` e o `play()` de um disparo não podem se
  /// intercalar com os do disparo seguinte do mesmo efeito: o `audioplayers`
  /// decide se vai tocar comparando um `desiredState` compartilhado, e um
  /// `stop()` que cai no meio do `play()` anterior faz o som sumir.
  final Map<String, Future<void>> _queues = <String, Future<void>>{};

  bool _lowLatency = true;

  @override
  Future<void> play(String asset, double volume) {
    final player = _players.putIfAbsent(
      asset,
      () => AudioPlayer()..setReleaseMode(ReleaseMode.stop),
    );

    final Future<void> queued = (_queues[asset] ?? Future<void>.value()).then(
      (_) => _playNow(player, asset, volume),
    );
    // A fila não pode morrer num erro: o próximo disparo tem de poder tentar.
    _queues[asset] = queued.catchError((Object _) {});
    return queued;
  }

  Future<void> _playNow(AudioPlayer player, String asset, double volume) async {
    // Devolve o player ao estado parado. Sem isto o `SoundPool` toca uma única
    // vez por player (ver o comentário da classe). Falhar aqui não impede a
    // tentativa de tocar.
    try {
      await player.stop();
    } catch (e) {
      log('SoundService: stop antes do play falhou: $e');
    }

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

    // `mode` explícito de propósito: o player já está em `lowLatency` depois da
    // tentativa acima, e sem pedir a troca o fallback não trocaria nada.
    await player.play(
      AssetSource(asset),
      volume: volume,
      mode: PlayerMode.mediaPlayer,
    );
  }

  @override
  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
    _queues.clear();
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
