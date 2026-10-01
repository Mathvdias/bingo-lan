import 'dart:io';

import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden tests para BingoInput
void main() {
  group('BingoInput Golden Tests', () {
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
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        filled: true,
        fillColor: AppColors.card,
      ),
    );

    testWidgets('BingoInput — estado padrão', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: BingoInput(hintText: 'Digite algo...'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(BingoInput),
        matchesGoldenFile('bingo_input_default.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets(
      'BingoInput — com texto preenchido',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  child: BingoInput(
                    controller: TextEditingController(
                      text: 'Texto já digitado',
                    ),
                    hintText: 'Digite algo...',
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(BingoInput),
          matchesGoldenFile('bingo_input_with_text.png'),
        );
      },
      skip: Platform.environment['CI'] == 'true',
    );

    testWidgets('BingoInput — modo senha', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: BingoInput(
                  obscureText: true,
                  hintText: 'Digite sua senha...',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(BingoInput),
        matchesGoldenFile('bingo_input_password.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('BingoInput — estado focado', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: BingoInput(hintText: 'Clique em mim...'),
              ),
            ),
          ),
        ),
      );

      // Dar foco ao campo
      await tester.tap(find.byType(BingoInput));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(BingoInput),
        matchesGoldenFile('bingo_input_focused.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('BingoInput — tema escuro', (tester) async {
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
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outline, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outline, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          filled: true,
          fillColor: AppColors.card,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: BingoInput(hintText: 'Digite algo escuro...'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(BingoInput),
        matchesGoldenFile('bingo_input_dark_theme.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('BingoInput — tamanho responsivo', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200, // Menor que o padrão
                child: BingoInput(hintText: 'Input pequeno...'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(BingoInput),
        matchesGoldenFile('bingo_input_small.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('BingoInput — tela cheia', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BingoInput(hintText: 'Input em tela cheia...'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(BingoInput),
        matchesGoldenFile('bingo_input_full_width.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets(
      'BingoInput — múltiplos estados lado a lado',
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
                    BingoInput(hintText: 'Campo normal...'),
                    const SizedBox(height: 16),
                    BingoInput(
                      controller: TextEditingController(text: 'Com texto'),
                      hintText: 'Com texto...',
                    ),
                    const SizedBox(height: 16),
                    BingoInput(obscureText: true, hintText: 'Senha...'),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(Column),
          matchesGoldenFile('bingo_input_variety.png'),
        );
      },
      skip: Platform.environment['CI'] == 'true',
    );
  });
}
