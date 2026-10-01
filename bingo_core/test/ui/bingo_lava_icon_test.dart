import 'package:bingo_core/bingo_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lava_flutter/lava_flutter.dart';

void main() {
  // Um future de carga iniciado num teste fake-async nunca completa; se ficasse
  // nos caches (do rootBundle e do LavaBundle), o teste seguinte, com runAsync,
  // esperaria por ele para sempre.
  void clearCaches() {
    rootBundle.clear();
    LavaBundle.evictOpenLavaCache();
  }

  setUp(clearCaches);
  tearDown(clearCaches);

  Widget wrap(Widget child, {bool disableAnimations = false}) {
    return MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: child),
      ),
    );
  }

  const fallback = Text('fallback', key: Key('fallback'));

  /// Monta o ícone e espera (com tempo real) o bundle decodificar.
  Future<void> pumpLoaded(
    WidgetTester tester, {
    bool disableAnimations = false,
  }) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        wrap(
          const BingoLavaIconView(
            icon: BingoLavaIcon.ball,
            size: 64,
            fallback: fallback,
          ),
          disableAnimations: disableAnimations,
        ),
      );
      for (var i = 0; i < 100; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pump();
        if (find.byType(LavaIcon).evaluate().isNotEmpty) break;
      }
    });
    await tester.pump();
  }

  group('BingoLavaIcon', () {
    test('cada ícone aponta para o bundle do pacote', () {
      expect(
        BingoLavaIcon.ball.assetPath,
        'packages/bingo_core/assets/lava/bingo_ball',
      );
      expect(
        BingoLavaIcon.values.map((icon) => icon.directory).toSet(),
        hasLength(BingoLavaIcon.values.length),
      );
    });
  });

  group('BingoLavaIconView', () {
    testWidgets('mostra o fallback no tamanho pedido antes do bundle carregar', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const BingoLavaIconView(
            icon: BingoLavaIcon.ball,
            size: 64,
            fallback: fallback,
          ),
        ),
      );
      expect(find.byKey(const Key('fallback')), findsOneWidget);
      expect(find.byType(LavaIcon), findsNothing);
      expect(
        tester.getSize(find.byType(BingoLavaIconView)),
        const Size(64, 64),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('troca pelo LavaIcon animado depois de decodificar', (
      tester,
    ) async {
      await pumpLoaded(tester);

      expect(find.byType(LavaIcon), findsOneWidget);
      expect(find.byKey(const Key('fallback')), findsNothing);
      expect(
        tester.getSize(find.byType(BingoLavaIconView)),
        const Size(64, 64),
      );
      expect(tester.widget<LavaIcon>(find.byType(LavaIcon)).autoPlay, isTrue);
      // Animando: sempre há um próximo quadro agendado.
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.binding.hasScheduledFrame, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fica parado quando o sistema pede menos animação', (
      tester,
    ) async {
      await pumpLoaded(tester, disableAnimations: true);

      expect(find.byType(LavaIcon), findsOneWidget);
      expect(tester.widget<LavaIcon>(find.byType(LavaIcon)).autoPlay, isFalse);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('bundle que não carrega mantém o fallback e reporta o erro', (
      tester,
    ) async {
      // Sem assets: o manifest.json falha e o fallback tem de ficar.
      tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
        (message) async => null,
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMessageHandler(
          'flutter/assets',
          null,
        ),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(
          wrap(
            const BingoLavaIconView(
              icon: BingoLavaIcon.ball,
              size: 48,
              fallback: fallback,
            ),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();

      expect(find.byKey(const Key('fallback')), findsOneWidget);
      expect(find.byType(LavaIcon), findsNothing);
      expect(
        tester.getSize(find.byType(BingoLavaIconView)),
        const Size(48, 48),
      );
      expect(tester.takeException(), isNotNull);
    });
  });
}
