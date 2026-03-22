import 'dart:io';

import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_grid_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden tests para BingoGridHeader
void main() {
  group('BingoGridHeader Golden Tests', () {
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
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.text,
        ),
      ),
    );

    testWidgets('BingoGridHeader — layout padrão', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                child: BingoGridHeader(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(BingoGridHeader),
        matchesGoldenFile('bingo_grid_header_default.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('BingoGridHeader — tema escuro', (tester) async {
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
          displaySmall: TextStyle(
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
              child: SizedBox(
                width: 400,
                child: BingoGridHeader(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(BingoGridHeader),
        matchesGoldenFile('bingo_grid_header_dark.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('BingoGridHeader — tamanho responsivo', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200, // Metade do tamanho
                child: BingoGridHeader(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(BingoGridHeader),
        matchesGoldenFile('bingo_grid_header_small.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('BingoGridHeader — tela cheia', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: double.infinity,
                child: BingoGridHeader(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(BingoGridHeader),
        matchesGoldenFile('bingo_grid_header_full_width.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');
  });
}
