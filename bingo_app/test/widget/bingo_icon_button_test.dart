import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  group('BingoIconButton', () {
    testWidgets('alvo de 48 px, semântica de botão com rótulo e toque', (
      tester,
    ) async {
      var taps = 0;
      await pumpApp(
        tester,
        Center(
          child: BingoIconButton(
            icon: Icons.logout,
            label: 'Encerrar sala',
            backgroundColor: AppColors.error,
            onPressed: () => taps++,
          ),
        ),
      );

      final finder = find.byType(BingoIconButton);
      expect(tester.getSize(finder), const Size(48, 48));
      expect(
        tester.getSemantics(find.bySemanticsLabel('Encerrar sala')),
        matchesSemantics(
          label: 'Encerrar sala',
          isButton: true,
          hasTapAction: true,
          hasEnabledState: true,
          isEnabled: true,
        ),
      );
      expect(find.byTooltip('Encerrar sala'), findsOneWidget);

      await tester.tap(finder);
      await tester.pump();
      expect(taps, 1);
    });
  });
}
