import 'package:bingo_app/shared/services/sound_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Sonda: exercita o SoundService no aparelho, sem UI e sem anúncios no
/// caminho. Serve para medir o logcat (`createTrack_l`) enquanto roda e
/// descobrir se o áudio realmente sai.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SONDA: toca cada efeito uma vez', (tester) async {
    final erros = <String>[];
    SoundService.onError = (e, s, reason) => erros.add('$reason: $e');

    await SoundService.initialize();
    debugPrintOverride('SONDA initialized=${SoundService.isInitialized} '
        'enabled=${SoundService.enabled.value} volume=${SoundService.volume.value}');

    for (final sfx in BingoSfx.values) {
      debugPrintOverride('SONDA tocando ${sfx.name}');
      SoundService.play(sfx);
      await tester.pump(const Duration(milliseconds: 1200));
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }

    debugPrintOverride('SONDA erros=${erros.isEmpty ? "nenhum" : erros}');
    expect(erros, isEmpty, reason: 'o serviço reportou falhas de áudio');
  });
}

/// `debugPrint` com prefixo fixo, para filtrar no logcat.
void debugPrintOverride(String message) {
  // ignore: avoid_print
  print('[SONDA] $message');
}
