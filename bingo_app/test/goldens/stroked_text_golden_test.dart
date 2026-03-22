import 'dart:io';

import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/stroked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden tests para StrokedText
void main() {
  group('StrokedText Golden Tests', () {
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
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.text,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.text,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.text,
        ),
      ),
    );

    testWidgets('StrokedText — texto simples', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: StrokedText(
                text: 'Bingo',
                style: theme.textTheme.displayLarge,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(StrokedText),
        matchesGoldenFile('stroked_text_simple.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('StrokedText — texto longo', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: StrokedText(
                text: 'Texto longo com stroke',
                style: theme.textTheme.headlineMedium,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(StrokedText),
        matchesGoldenFile('stroked_text_long.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('StrokedText — stroke width padrão', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: StrokedText(
                text: 'Stroke Normal',
                style: theme.textTheme.headlineMedium,
                strokeWidth: 2.0,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(StrokedText),
        matchesGoldenFile('stroked_text_normal_width.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('StrokedText — stroke width fino', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: StrokedText(
                text: 'Stroke Fino',
                style: theme.textTheme.headlineMedium,
                strokeWidth: 0.5,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(StrokedText),
        matchesGoldenFile('stroked_text_thin_width.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('StrokedText — stroke width grosso', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: StrokedText(
                text: 'Stroke Grosso',
                style: theme.textTheme.headlineMedium,
                strokeWidth: 4.0,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(StrokedText),
        matchesGoldenFile('stroked_text_thick_width.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('StrokedText — tema escuro', (tester) async {
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
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          home: Scaffold(
            body: Center(
              child: StrokedText(
                text: 'Dark Theme',
                style: darkTheme.textTheme.displayLarge,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(StrokedText),
        matchesGoldenFile('stroked_text_dark_theme.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('StrokedText — múltiplos tamanhos', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StrokedText(
                    text: 'Grande',
                    style: theme.textTheme.displayLarge,
                  ),
                  const SizedBox(height: 16),
                  StrokedText(
                    text: 'Médio',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  StrokedText(
                    text: 'Pequeno',
                    style: theme.textTheme.bodyLarge,
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
        matchesGoldenFile('stroked_text_multiple_sizes.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('StrokedText — diferentes stroke widths', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StrokedText(
                    text: 'Fino',
                    style: theme.textTheme.headlineMedium,
                    strokeWidth: 0.5,
                  ),
                  const SizedBox(height: 16),
                  StrokedText(
                    text: 'Normal',
                    style: theme.textTheme.headlineMedium,
                    strokeWidth: 2.0,
                  ),
                  const SizedBox(height: 16),
                  StrokedText(
                    text: 'Grosso',
                    style: theme.textTheme.headlineMedium,
                    strokeWidth: 4.0,
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
        matchesGoldenFile('stroked_text_multiple_widths.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('StrokedText — em contexto de Container', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: StrokedText(
                  text: 'Dentro Container',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(Container),
        matchesGoldenFile('stroked_text_in_container.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('StrokedText — texto especial (números e símbolos)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: StrokedText(
                text: 'BINGO 123! @#%',
                style: theme.textTheme.displayLarge,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(StrokedText),
        matchesGoldenFile('stroked_text_special_chars.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');
  });
}
