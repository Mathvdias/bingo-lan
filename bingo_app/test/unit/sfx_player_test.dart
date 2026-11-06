import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:bingo_app/shared/services/sound_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Testes do [AudioPlayersSfxPlayer] contra um `audioplayers` falso, no nível
/// do canal de plataforma.
///
/// Existem porque o bug que eles travam não aparece em nenhuma camada acima:
/// o [SoundService] chamava `play` direitinho, os asserts contra um [SfxPlayer]
/// falso passavam, e o aparelho ficava mudo depois dos primeiros sons. O
/// `SoundPool` do Android não avisa quando um som termina, então o
/// `audioplayers` deixa o player marcado como "tocando" para sempre e ignora
/// todo `play()` seguinte. A única forma de ver isso num teste é olhar as
/// chamadas que chegam na plataforma.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeAudioplayersPlatform platform;

  setUp(() {
    // Antes de qualquer toque em AudioPlayer: o `AudioPlayer.global` é um
    // estático preguiçoso que captura a plataforma global ao ser criado.
    GlobalAudioplayersPlatformInterface.instance = _FakeGlobalPlatform();
    platform = _FakeAudioplayersPlatform();
    AudioplayersPlatformInterface.instance = platform;
    AudioCache.instance = _SystemTempAudioCache();
  });

  group('AudioPlayersSfxPlayer', () {
    test('para o player antes de cada disparo', () async {
      final player = AudioPlayersSfxPlayer();
      addTearDown(player.dispose);

      await player.play('audio/mark.wav', 0.7);
      await player.play('audio/mark.wav', 0.7);
      await player.play('audio/mark.wav', 0.7);

      // É o `stop` que devolve o `playing` e o `streamId` do lado nativo ao
      // estado inicial. Sem ele o `SoundPool` toca uma vez por player e
      // ignora o resto — e o silêncio acontece dentro do Kotlin, sem erro,
      // então é o `stop` que este teste tem de ver para dar garantia.
      final sequence = platform.calls
          .where((c) => c.method == 'stop' || c.method == 'resume')
          .map((c) => c.method)
          .toList();
      expect(sequence, [
        'stop',
        'resume',
        'stop',
        'resume',
        'stop',
        'resume',
      ]);
    });

    test('um player por efeito, reaproveitado entre disparos', () async {
      final player = AudioPlayersSfxPlayer();
      addTearDown(player.dispose);

      await player.play('audio/mark.wav', 0.7);
      await player.play('audio/unmark.wav', 0.7);
      await player.play('audio/mark.wav', 0.7);

      final sources = platform.callsOf('setSourceUrl');
      expect(sources, hasLength(3));

      // mark e unmark em players diferentes, para poderem se sobrepor...
      expect(sources[0].playerId, isNot(sources[1].playerId));
      // ...e o segundo mark no mesmo player do primeiro, porque trocar a fonte
      // de um player do SoundPool deixa a amostra antiga apontando para o
      // `soundId` errado.
      expect(sources[2].playerId, sources[0].playerId);
    });

    test('leva o volume pedido para a plataforma', () async {
      final player = AudioPlayersSfxPlayer();
      addTearDown(player.dispose);

      await player.play('audio/draw.wav', 0.25);

      expect(platform.callsOf('setVolume').last.argument, 0.25);
    });

    test('pede o modo de baixa latência', () async {
      final player = AudioPlayersSfxPlayer();
      addTearDown(player.dispose);

      await player.play('audio/draw.wav', 0.7);

      expect(
        platform.callsOf('setPlayerMode').map((c) => c.argument),
        contains(PlayerMode.lowLatency),
      );
    });

    test('cai para o modo padrão se a baixa latência falhar', () async {
      final player = AudioPlayersSfxPlayer();
      addTearDown(player.dispose);

      platform.failNextResume = true;
      await player.play('audio/mark.wav', 0.7);

      // Um pouco de latência é melhor que silêncio: o disparo que falhou é
      // repetido no modo padrão, e o modo é de fato pedido à plataforma.
      expect(
        platform.callsOf('setPlayerMode').map((c) => c.argument),
        containsAllInOrder([PlayerMode.lowLatency, PlayerMode.mediaPlayer]),
      );
      expect(platform.callsOf('resume'), hasLength(2));

      // E a fila do efeito não morreu no erro: o disparo seguinte sai.
      await player.play('audio/mark.wav', 0.7);
      expect(platform.callsOf('resume'), hasLength(3));
    });
  });
}

/// Um `AudioCache` que escreve no temporário do sistema em vez de pedir o
/// diretório ao `path_provider`, que não tem canal nativo em teste.
class _SystemTempAudioCache extends AudioCache {
  @override
  Future<String> getTempDir() async => Directory.systemTemp.path;
}

class _Call {
  _Call(this.method, this.playerId, [this.argument]);

  final String method;
  final String playerId;
  final Object? argument;

  @override
  String toString() => '$method($playerId, $argument)';
}

class _FakeAudioplayersPlatform extends AudioplayersPlatformInterface {
  final List<_Call> calls = <_Call>[];
  final Map<String, StreamController<AudioEvent>> _events =
      <String, StreamController<AudioEvent>>{};

  bool failNextResume = false;

  List<_Call> callsOf(String method) =>
      calls.where((c) => c.method == method).toList();

  void _record(String method, String playerId, [Object? argument]) =>
      calls.add(_Call(method, playerId, argument));

  @override
  Future<void> create(String playerId) async {
    _record('create', playerId);
    _events[playerId] = StreamController<AudioEvent>.broadcast();
  }

  @override
  Stream<AudioEvent> getEventStream(String playerId) =>
      _events[playerId]!.stream;

  @override
  Future<void> setSourceUrl(
    String playerId,
    String url, {
    bool? isLocal,
    String? mimeType,
  }) async {
    _record('setSourceUrl', playerId, url);
    // O nativo responde com `prepared`; sem isto o `setSource` do
    // `audioplayers` fica esperando até o timeout de 30 s.
    scheduleMicrotask(() {
      _events[playerId]?.add(
        const AudioEvent(
          eventType: AudioEventType.prepared,
          isPrepared: true,
        ),
      );
    });
  }

  @override
  Future<void> resume(String playerId) async {
    _record('resume', playerId);
    if (failNextResume) {
      failNextResume = false;
      throw Exception('falha simulada de plataforma');
    }
  }

  @override
  Future<void> stop(String playerId) async => _record('stop', playerId);

  @override
  Future<void> pause(String playerId) async => _record('pause', playerId);

  @override
  Future<void> release(String playerId) async => _record('release', playerId);

  @override
  Future<void> dispose(String playerId) async {
    _record('dispose', playerId);
    await _events.remove(playerId)?.close();
  }

  @override
  Future<void> seek(String playerId, Duration position) async =>
      _record('seek', playerId, position);

  @override
  Future<void> setVolume(String playerId, double volume) async =>
      _record('setVolume', playerId, volume);

  @override
  Future<void> setBalance(String playerId, double balance) async =>
      _record('setBalance', playerId, balance);

  @override
  Future<void> setPlaybackRate(String playerId, double playbackRate) async =>
      _record('setPlaybackRate', playerId, playbackRate);

  @override
  Future<void> setReleaseMode(String playerId, ReleaseMode releaseMode) async =>
      _record('setReleaseMode', playerId, releaseMode);

  @override
  Future<void> setPlayerMode(String playerId, PlayerMode playerMode) async =>
      _record('setPlayerMode', playerId, playerMode);

  @override
  Future<void> setAudioContext(String playerId, AudioContext ctx) async =>
      _record('setAudioContext', playerId, ctx);

  @override
  Future<void> setSourceBytes(
    String playerId,
    Uint8List bytes, {
    String? mimeType,
  }) async =>
      _record('setSourceBytes', playerId);

  @override
  Future<int?> getDuration(String playerId) async => null;

  @override
  Future<int?> getCurrentPosition(String playerId) async => null;

  @override
  Future<void> emitLog(String playerId, String message) async {}

  @override
  Future<void> emitError(
    String playerId,
    String code,
    String message,
  ) async {}
}

class _FakeGlobalPlatform implements GlobalAudioplayersPlatformInterface {
  @override
  Future<void> init() async {}

  @override
  Future<void> setGlobalAudioContext(AudioContext ctx) async {}

  @override
  Stream<GlobalAudioEvent> getGlobalEventStream() =>
      const Stream<GlobalAudioEvent>.empty();

  @override
  Future<void> emitGlobalLog(String message) async {}

  @override
  Future<void> emitGlobalError(String code, String message) async {}
}
