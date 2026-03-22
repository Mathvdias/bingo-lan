import 'package:bingo_app/shared/ui/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BingoBackButton chama onPressed', (tester) async {
    var back = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BingoBackButton(
            onPressed: () => back = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(BingoBackButton));
    expect(back, isTrue);
  });

  testWidgets('BingoBackButton usa Navigator.pop quando onPressed null', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Column(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => Scaffold(
                            body: BingoBackButton(),
                          ),
                        ),
                      );
                    },
                    child: const Text('open'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BingoBackButton));
    await tester.pumpAndSettle();
    expect(find.text('open'), findsOneWidget);
  });
}
