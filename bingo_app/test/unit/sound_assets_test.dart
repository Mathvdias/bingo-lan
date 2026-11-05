import 'package:bingo_app/shared/services/sound_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Garante que todo [BingoSfx] tem um arquivo declarado no pubspec e
/// empacotado. Sem isto, renomear um .wav só apareceria como silêncio no
/// dispositivo — o [SoundService] engole a falha de propósito.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('assets de áudio', () {
    for (final sfx in BingoSfx.values) {
      test('${sfx.name}.wav está no bundle e é um WAV válido', () async {
        final data = await rootBundle.load('assets/audio/${sfx.name}.wav');

        expect(
          data.lengthInBytes,
          greaterThan(1000),
          reason: 'arquivo vazio ou truncado',
        );

        final header = data.buffer.asUint8List(0, 12);
        expect(
          String.fromCharCodes(header.sublist(0, 4)),
          'RIFF',
          reason: 'não começa com o cabeçalho RIFF',
        );
        expect(
          String.fromCharCodes(header.sublist(8, 12)),
          'WAVE',
          reason: 'RIFF que não é WAVE',
        );
      });
    }
  });
}
