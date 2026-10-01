import 'dart:io';

import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden tests para BingoBackButton
void main() {
  group('BingoBackButton Golden Tests', () {
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
      iconTheme: const IconThemeData(color: AppColors.text, size: 20),
    );

    testWidgets('BingoBackButton — estado padrão', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(body: Center(child: BingoBackButton())),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(BingoBackButton),
        matchesGoldenFile('bingo_back_button_default.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets(
      'BingoBackButton — com cor de fundo personalizada',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Center(
                child: BingoBackButton(backgroundColor: AppColors.primary),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(BingoBackButton),
          matchesGoldenFile('bingo_back_button_custom_bg.png'),
        );
      },
      skip: Platform.environment['CI'] == 'true',
    );

    testWidgets(
      'BingoBackButton — com onPressed customizado',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Center(child: BingoBackButton(onPressed: () {})),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(BingoBackButton),
          matchesGoldenFile('bingo_back_button_custom_handler.png'),
        );
      },
      skip: Platform.environment['CI'] == 'true',
    );

    testWidgets('BingoBackButton — tema escuro', (tester) async {
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
        iconTheme: const IconThemeData(color: AppColors.text, size: 20),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          home: Scaffold(body: Center(child: BingoBackButton())),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(BingoBackButton),
        matchesGoldenFile('bingo_back_button_dark_theme.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets(
      'BingoBackButton — em contexto de AppBar',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Test'),
                leading: BingoBackButton(),
              ),
              body: const Center(child: Text('Content')),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(AppBar),
          matchesGoldenFile('bingo_back_button_in_appbar.png'),
        );
      },
      skip: Platform.environment['CI'] == 'true',
    );

    testWidgets(
      'BingoBackButton — múltiplos estilos lado a lado',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BingoBackButton(),
                    const SizedBox(width: 16),
                    BingoBackButton(backgroundColor: AppColors.primary),
                    const SizedBox(width: 16),
                    BingoBackButton(backgroundColor: AppColors.secondary),
                    const SizedBox(width: 16),
                    BingoBackButton(backgroundColor: AppColors.error),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(Row),
          matchesGoldenFile('bingo_back_button_variety.png'),
        );
      },
      skip: Platform.environment['CI'] == 'true',
    );

    testWidgets(
      'BingoBackButton — teste de interação básica',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Center(child: BingoBackButton(onPressed: () {})),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Testar se o botão é encontrável e clicável
        expect(find.byType(BingoBackButton), findsOneWidget);

        // Simular um tap
        await tester.tap(find.byType(BingoBackButton));
        await tester.pumpAndSettle();

        // Verificar que o Scaffold ainda existe após o tap
        expect(find.byType(Scaffold), findsOneWidget);

        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile('bingo_back_button_after_tap.png'),
        );
      },
      skip: Platform.environment['CI'] == 'true',
    );
  });
}
