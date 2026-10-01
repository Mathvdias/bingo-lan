import 'package:bingo_app/shared/ui/app_theme.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BingoButton exibe o rótulo e dispara onPressed', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: bingoTheme,
        home: Scaffold(
          body: BingoButton(label: 'Jogar', onPressed: () => tapped = true),
        ),
      ),
    );

    expect(find.text('JOGAR'), findsOneWidget);
    await tester.tap(find.text('JOGAR'));
    await tester.pump();
    expect(tapped, isTrue);
  });
}
