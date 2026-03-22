import 'dart:io';

import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/card_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden tests para CardCell em diferentes estados
void main() {
  group('CardCell Golden Tests', () {
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
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
      ),
    );

    testWidgets('CardCell — estado normal', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 80,
                height: 80,
                child: CardCell(number: 17),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(CardCell),
        matchesGoldenFile('card_cell_normal.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('CardCell — FREE center', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 80,
                height: 80,
                child: CardCell(number: 0),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(CardCell),
        matchesGoldenFile('card_cell_free.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('CardCell — estado marked', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 80,
                height: 80,
                child: CardCell(number: 25, state: CardCellState.marked),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(CardCell),
        matchesGoldenFile('card_cell_marked.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('CardCell — estado validated', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 80,
                height: 80,
                child: CardCell(number: 42, state: CardCellState.validated),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(CardCell),
        matchesGoldenFile('card_cell_validated.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');

    testWidgets('CardCell — múltiplos estados lado a lado', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CardCell(number: 10),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CardCell(number: 0),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CardCell(number: 20, state: CardCellState.marked),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CardCell(number: 30, state: CardCellState.validated),
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
        matchesGoldenFile('card_cell_all_states.png'),
      );
    }, skip: Platform.environment['CI'] == 'true');
  });
}
