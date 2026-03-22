import 'dart:io';

import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/flippable_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden tests para FlippableCard
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

    testWidgets('FlippableCard — lado frontal', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: FlippableCard(
                  image:
                      'assets/images/bingo_logo.png', // Usar asset existente ou criar placeholder
                  text: 'Texto do verso',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
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

      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: FlippableCard(
                  image: 'assets/images/logo.png',
                  text: 'Texto do verso escuro',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(FlippableCard),
        matchesGoldenFile('flippable_card_dark_theme.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets(
      'FlippableCard — tamanho responsivo',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 200, // Menor que o padrão
                  height: 200,
                  child: FlippableCard(
                    image: 'assets/images/logo.png',
                    text: 'Texto pequeno',
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(FlippableCard),
          matchesGoldenFile('flippable_card_small.png'),
        );
      },
      skip: Platform.environment['CI'] == 'true',
    );

    testWidgets('FlippableCard — tamanho grande', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400, // Maior que o padrão
                height: 400,
                child: FlippableCard(image: 'assets/images/logo.png', text: 'Texto grande'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(FlippableCard),
        matchesGoldenFile('flippable_card_large.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('FlippableCard — texto longo', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: FlippableCard(
                  image: 'assets/images/logo.png', // Usar asset existente
                  text:
                      'Este é um texto muito longo que deve ser exibido no verso do card. Ele serve para testar como o componente lida com textos longos e se há quebra de linha adequada.',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(FlippableCard),
        matchesGoldenFile('flippable_card_long_text.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets(
      'FlippableCard — múltiplos cards lado a lado',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: FlippableCard(image: 'assets/images/logo.png', text: 'Card 1'),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: FlippableCard(image: 'assets/images/logo.png', text: 'Card 2'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
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
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Cards Flippáveis',
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: FlippableCard(
                        image: 'assets/images/logo.png',
                        text: 'Card em coluna',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
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
            ),
          ),
        );
        await tester.pumpAndSettle();
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
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: FlippableCard(
                    image: 'assets/images/logo.png',
                    text: 'Clique para virar',
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

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
