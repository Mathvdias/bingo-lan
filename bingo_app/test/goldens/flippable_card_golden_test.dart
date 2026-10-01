import 'dart:io';

import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/flippable_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key.endsWith('.png')) {
      return ByteData.sublistView(
        Uint8List.fromList([
          0x89,
          0x50,
          0x4E,
          0x47,
          0x0D,
          0x0A,
          0x1A,
          0x0A,
          0x00,
          0x00,
          0x00,
          0x0D,
          0x49,
          0x48,
          0x44,
          0x52,
          0x00,
          0x00,
          0x00,
          0x01,
          0x00,
          0x00,
          0x00,
          0x01,
          0x08,
          0x06,
          0x00,
          0x00,
          0x00,
          0x1F,
          0x15,
          0xC4,
          0x89,
          0x00,
          0x00,
          0x00,
          0x0A,
          0x49,
          0x44,
          0x41,
          0x54,
          0x78,
          0x9C,
          0x63,
          0x00,
          0x01,
          0x00,
          0x00,
          0x05,
          0x00,
          0x01,
          0x0D,
          0x0A,
          0x2D,
          0xB4,
          0x00,
          0x00,
          0x00,
          0x00,
          0x49,
          0x45,
          0x4E,
          0x44,
          0xAE,
          0x42,
          0x60,
          0x82,
        ]),
      );
    }
    return PlatformAssetBundle().load(key);
  }
}

void main() {
  group('FlippableCard Golden Tests', () {
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.text,
        secondary: AppColors.secondary,
        onSecondary: AppColors.text,
        surface: AppColors.card,
        onSurface: AppColors.text,
        error: AppColors.error,
        onError: AppColors.text,
      ),
      cardTheme: const CardThemeData(elevation: 4.0, color: AppColors.card),
    );

    Future<void> pumpCard(
      WidgetTester tester,
      Widget child,
      ThemeData currentTheme,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: currentTheme,
          home: Scaffold(
            body: Center(
              child: DefaultAssetBundle(
                bundle: MockAssetBundle(),
                child: child,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('FlippableCard — lado frontal', (tester) async {
      await pumpCard(
        tester,
        const SizedBox(
          width: 300,
          height: 300,
          child: FlippableCard(
            image: 'assets/images/logo.png',
            text: 'Texto do verso',
          ),
        ),
        theme,
      );
      await expectLater(
        find.byType(FlippableCard),
        matchesGoldenFile('flippable_card_front.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('FlippableCard — tema escuro', (tester) async {
      final darkTheme = ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          onPrimary: AppColors.text,
          secondary: AppColors.secondary,
          onSecondary: AppColors.text,
          surface: AppColors.card,
          onSurface: AppColors.text,
          error: AppColors.error,
          onError: AppColors.text,
        ),
        cardTheme: const CardThemeData(elevation: 4.0, color: AppColors.card),
      );

      await pumpCard(
        tester,
        const SizedBox(
          width: 300,
          height: 300,
          child: FlippableCard(
            image: 'assets/images/logo.png',
            text: 'Texto do verso escuro',
          ),
        ),
        darkTheme,
      );
      await expectLater(
        find.byType(FlippableCard),
        matchesGoldenFile('flippable_card_dark_theme.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets(
      'FlippableCard — tamanho responsivo',
      (tester) async {
        await pumpCard(
          tester,
          const SizedBox(
            width: 200,
            height: 200,
            child: FlippableCard(
              image: 'assets/images/logo.png',
              text: 'Texto pequeno',
            ),
          ),
          theme,
        );
        await expectLater(
          find.byType(FlippableCard),
          matchesGoldenFile('flippable_card_small.png'),
        );
      },
      skip: Platform.environment['CI'] == 'true',
    );

    testWidgets('FlippableCard — tamanho grande', (tester) async {
      await pumpCard(
        tester,
        const SizedBox(
          width: 400,
          height: 400,
          child: FlippableCard(
            image: 'assets/images/logo.png',
            text: 'Texto grande',
          ),
        ),
        theme,
      );
      await expectLater(
        find.byType(FlippableCard),
        matchesGoldenFile('flippable_card_large.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('FlippableCard — texto longo', (tester) async {
      await pumpCard(
        tester,
        const SizedBox(
          width: 300,
          height: 300,
          child: FlippableCard(
            image: 'assets/images/logo.png',
            text:
                'Este é um texto muito longo que deve ser exibido no verso do card. Ele serve para testar como o componente lida com textos longos e se há quebra de linha adequada.',
          ),
        ),
        theme,
      );
      await expectLater(
        find.byType(FlippableCard),
        matchesGoldenFile('flippable_card_long_text.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets(
      'FlippableCard — múltiplos cards lado a lado',
      (tester) async {
        await pumpCard(
          tester,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 150,
                height: 150,
                child: FlippableCard(
                  image: 'assets/images/logo.png',
                  text: 'Card 1',
                ),
              ),
              const SizedBox(width: 16),
              const SizedBox(
                width: 150,
                height: 150,
                child: FlippableCard(
                  image: 'assets/images/logo.png',
                  text: 'Card 2',
                ),
              ),
            ],
          ),
          theme,
        );
        await expectLater(
          find.byType(Row),
          matchesGoldenFile('flippable_card_multiple.png'),
        );
      },
      skip: Platform.environment['CI'] == 'true',
    );

    testWidgets(
      'FlippableCard — em contexto de Column',
      (tester) async {
        await pumpCard(
          tester,
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Cards Flippáveis', style: TextStyle(fontSize: 24)),
                const SizedBox(height: 16),
                const SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: FlippableCard(
                    image: 'assets/images/logo.png',
                    text: 'Card em coluna',
                  ),
                ),
                const SizedBox(height: 16),
                const SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: FlippableCard(
                    image: 'assets/images/logo.png',
                    text: 'Outro card',
                  ),
                ),
              ],
            ),
          ),
          theme,
        );
        await expectLater(
          find.byType(Column),
          matchesGoldenFile('flippable_card_in_column.png'),
        );
      },
      skip: Platform.environment['CI'] == 'true',
    );

    testWidgets(
      'FlippableCard — teste de interação',
      (tester) async {
        await pumpCard(
          tester,
          const SizedBox(
            width: 300,
            height: 300,
            child: FlippableCard(
              image: 'assets/images/logo.png',
              text: 'Clique para virar',
            ),
          ),
          theme,
        );

        // Testar se o card é encontrável
        expect(find.byType(FlippableCard), findsOneWidget);

        // Simular um tap (o flip card deve responder)
        await tester.tap(find.byType(FlippableCard));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(FlippableCard),
          matchesGoldenFile('flippable_card_after_tap.png'),
        );
      },
      skip: Platform.environment['CI'] == 'true',
    );
  });
}
