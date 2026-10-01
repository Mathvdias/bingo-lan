import 'package:bingo_core/bingo_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lava_flutter/lava_flutter.dart';

void main() {
  void clearCaches() {
    rootBundle.clear();
    LavaBundle.evictOpenLavaCache();
  }

  setUp(clearCaches);
  tearDown(clearCaches);

  const virtualKey = Key('tab_virtual');
  const manualKey = Key('tab_manual');

  Widget tabs({required int selected, bool disableAnimations = false}) {
    return MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BingoLavaTabIcon(
              key: virtualKey,
              icon: BingoLavaIcon.dice,
              selected: selected == 0,
              size: 32,
              fallback: const Text('dice'),
            ),
            BingoLavaTabIcon(
              key: manualKey,
              icon: BingoLavaIcon.pencil,
              selected: selected == 1,
              size: 32,
              fallback: const Text('pencil'),
            ),
          ],
        ),
      ),
    );
  }

  LavaController controllerOf(WidgetTester tester, Key key) {
    final icon = tester.widget<LavaIcon>(
      find.descendant(of: find.byKey(key), matching: find.byType(LavaIcon)),
    );
    return icon.controller!;
  }

  /// Monta as duas abas e espera (tempo real) os dois bundles decodificarem.
  Future<void> pumpLoaded(
    WidgetTester tester, {
    int selected = 0,
    bool disableAnimations = false,
  }) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        tabs(selected: selected, disableAnimations: disableAnimations),
      );
      for (var i = 0; i < 100; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pump();
        if (find.byType(LavaIcon).evaluate().length == 2) break;
      }
    });
    await tester.pump();
    expect(find.byType(LavaIcon), findsNWidgets(2));
  }

  group('BingoLavaTabIcon', () {
    testWidgets('mostra o fallback no tamanho pedido antes de carregar', (
      tester,
    ) async {
      await tester.pumpWidget(tabs(selected: 0));
      expect(find.text('dice'), findsOneWidget);
      expect(find.text('pencil'), findsOneWidget);
      expect(tester.getSize(find.byKey(virtualKey)), const Size(32, 32));
      expect(tester.takeException(), isNull);
    });

    testWidgets('selecionada ao nascer fica parada no último quadro', (
      tester,
    ) async {
      await pumpLoaded(tester);

      final virtual = controllerOf(tester, virtualKey);
      final manual = controllerOf(tester, manualKey);
      expect(virtual.isPlaying, isFalse);
      expect(virtual.currentFrame, virtual.totalFrames - 1);
      expect(manual.isPlaying, isFalse);
      expect(manual.currentFrame, 0);
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('selecionar uma aba toca o ícone uma vez; a outra fica no 0', (
      tester,
    ) async {
      await pumpLoaded(tester);
      await tester.pumpWidget(tabs(selected: 1));

      final virtual = controllerOf(tester, virtualKey);
      final manual = controllerOf(tester, manualKey);
      expect(manual.isPlaying, isTrue);
      expect(manual.currentFrame, 0);
      expect(virtual.isPlaying, isFalse);
      expect(virtual.currentFrame, 0);

      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 200));
      expect(manual.currentFrame, greaterThan(0));
      expect(virtual.currentFrame, 0);

      // Passa do fim do bundle: parado no último quadro, sem quadros agendados.
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 200));
      expect(manual.isPlaying, isFalse);
      expect(manual.currentFrame, manual.totalFrames - 1);
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('com menos animação a seleção pula para o último quadro', (
      tester,
    ) async {
      await pumpLoaded(tester, disableAnimations: true);
      await tester.pumpWidget(tabs(selected: 1, disableAnimations: true));

      final manual = controllerOf(tester, manualKey);
      expect(manual.isPlaying, isFalse);
      expect(manual.currentFrame, manual.totalFrames - 1);
      expect(controllerOf(tester, virtualKey).currentFrame, 0);
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(tester.takeException(), isNull);
    });
  });
}
