import 'dart:io';

import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_ball.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden tests para BingoBall em diferentes estados
void main() {
  group('BingoBall Golden Tests', () {
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
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.text,
        ),
      ),
    );

    testWidgets('BingoBall — estado normal (não sorteado)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: BingoBall(number: 75),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(BingoBall),
        matchesGoldenFile('bingo_ball_normal.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('BingoBall — estado sorteado', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: BingoBall(number: 75, isDrawn: true),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(BingoBall),
        matchesGoldenFile('bingo_ball_drawn.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('BingoBall — tamanho pequeno', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: BingoBall(number: 42, size: 40.0),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(BingoBall),
        matchesGoldenFile('bingo_ball_small.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('BingoBall — tamanho grande', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: BingoBall(number: 23, size: 80.0),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(BingoBall),
        matchesGoldenFile('bingo_ball_large.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('BingoBall — números de 1 dígito', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: BingoBall(number: 7),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(BingoBall),
        matchesGoldenFile('bingo_ball_single_digit.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('BingoBall — números de 2 dígitos', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: BingoBall(number: 75),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(BingoBall),
        matchesGoldenFile('bingo_ball_double_digit.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('BingoBall — múltiplos estados lado a lado', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BingoBall(number: 7),
                  const SizedBox(width: 8),
                  BingoBall(number: 75, isDrawn: true),
                  const SizedBox(width: 8),
                  BingoBall(number: 42, size: 40.0),
                  const SizedBox(width: 8),
                  BingoBall(number: 23, isDrawn: true, size: 80.0),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(Row),
        matchesGoldenFile('bingo_ball_variety.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('BingoBall — tema escuro', (tester) async {
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
              child: BingoBall(number: 75, isDrawn: true),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(BingoBall),
        matchesGoldenFile('bingo_ball_dark_theme.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');
  });
}
