import 'package:bingo_app/shared/ui/widgets/bingo_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BingoInput renderiza hint e repassa onChanged', (tester) async {
    final controller = TextEditingController();
    final changes = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BingoInput(
            controller: controller,
            hintText: 'Nome da sala',
            onChanged: changes.add,
          ),
        ),
      ),
    );

    expect(find.byType(TextFormField), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'abc');
    expect(changes, contains('abc'));
  });
}
