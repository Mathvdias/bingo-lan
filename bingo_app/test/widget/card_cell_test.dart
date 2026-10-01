import 'package:bingo_app/shared/ui/widgets/card_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CardCell mostra número e FREE', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              SizedBox(width: 80, height: 80, child: CardCell(number: 17)),
              SizedBox(width: 80, height: 80, child: CardCell(number: 0)),
            ],
          ),
        ),
      ),
    );

    expect(find.text('17'), findsOneWidget);
    expect(find.text('FREE'), findsOneWidget);
  });

  testWidgets('CardCell onTap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 80,
            height: 80,
            child: CardCell(number: 5, onTap: () => taps++),
          ),
        ),
      ),
    );

    await tester.tap(find.text('5'));
    expect(taps, 1);
  });
}
