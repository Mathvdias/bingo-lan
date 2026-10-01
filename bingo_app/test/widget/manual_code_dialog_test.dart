import 'package:bingo_app/features/player/widgets/manual_code_dialog.dart';
import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_theme.dart';

/// Monta um botão que abre o diálogo e guarda o resultado em [result].
Future<void> _pumpHost(
  WidgetTester tester,
  void Function(String? code) onResult, {
  required ValueNotifier<double> bottomInset,
}) async {
  tester.view.physicalSize = const Size(360, 640);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: testBingoTheme,
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Simula o teclado abrindo/fechando: muda os viewInsets e força o
      // diálogo a reconstruir, como acontece no aparelho.
      builder: (context, app) => ValueListenableBuilder<double>(
        valueListenable: bottomInset,
        builder: (context, inset, _) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(viewInsets: EdgeInsets.only(bottom: inset)),
          child: app!,
        ),
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              key: const Key('open'),
              onPressed: () async {
                onResult(await showManualCodeDialog(context));
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.byKey(const Key('open')));
  await tester.pumpAndSettle();
}

void main() {
  group('ManualCodeDialog', () {
    testWidgets('texto digitado em duas levas chega inteiro e na ordem', (
      tester,
    ) async {
      String? result;
      final inset = ValueNotifier<double>(0);
      addTearDown(inset.dispose);
      await _pumpHost(tester, (code) => result = code, bottomInset: inset);

      final field = find.byKey(const Key('manual_code_field'));
      expect(field, findsOneWidget);
      final controllerBefore = tester.widget<TextField>(field).controller;

      await tester.enterText(field, 'bingo://join?data=abc');
      await tester.pump();

      // Teclado "abre": o diálogo reconstrói; o controller não pode trocar.
      inset.value = 300;
      await tester.pumpAndSettle();
      final controllerAfter = tester.widget<TextField>(field).controller;
      expect(identical(controllerBefore, controllerAfter), isTrue);
      expect(controllerAfter!.text, 'bingo://join?data=abc');

      await tester.enterText(field, 'bingo://join?data=abcDEF');
      await tester.pump();
      expect(controllerAfter.text, 'bingo://join?data=abcDEF');
      expect(
        controllerAfter.selection.baseOffset,
        'bingo://join?data=abcDEF'.length,
      );

      await tester.tap(find.byKey(const Key('manual_code_join')));
      await tester.pumpAndSettle();

      expect(result, 'bingo://join?data=abcDEF');
      expect(find.byType(ManualCodeDialog), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('entrar com campo vazio não fecha; cancelar devolve null', (
      tester,
    ) async {
      String? result = 'sentinela';
      final inset = ValueNotifier<double>(0);
      addTearDown(inset.dispose);
      await _pumpHost(tester, (code) => result = code, bottomInset: inset);

      await tester.enterText(find.byKey(const Key('manual_code_field')), '   ');
      await tester.tap(find.byKey(const Key('manual_code_join')));
      await tester.pumpAndSettle();
      expect(find.byType(ManualCodeDialog), findsOneWidget);

      await tester.tap(find.byKey(const Key('manual_code_cancel')));
      await tester.pumpAndSettle();
      expect(find.byType(ManualCodeDialog), findsNothing);
      expect(result, isNull);
    });
  });
}
