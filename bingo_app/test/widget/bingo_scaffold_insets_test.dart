import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_theme.dart';

/// O app é edge-to-edge (targetSdk 36; o Android 15+ impõe de todo jeito),
/// então o conteúdo desenha sob a barra de navegação. Sem recuo, o rodapé das
/// telas fica embaixo dos três botões virtuais.
void main() {
  const double navBar = 48.0;
  const Size screen = Size(360, 740);

  Future<void> pumpScaffold(
    WidgetTester tester, {
    required Widget body,
    Widget? bottomNavigationBar,
  }) async {
    tester.view.physicalSize = screen;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: testBingoTheme,
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          // Simula a barra de navegação ocupando o rodapé.
          data: MediaQuery.of(context).copyWith(
            padding: const EdgeInsets.only(bottom: navBar),
            viewPadding: const EdgeInsets.only(bottom: navBar),
          ),
          child: child!,
        ),
        home: BingoScaffold(
          title: 'Teste',
          body: body,
          bottomNavigationBar: bottomNavigationBar,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('BingoScaffold e a barra de navegação', () {
    testWidgets('o corpo não encosta na barra', (tester) async {
      await pumpScaffold(
        tester,
        body: const SizedBox.expand(key: Key('corpo')),
      );

      final bottom = tester.getBottomLeft(find.byKey(const Key('corpo'))).dy;
      expect(bottom, moreOrLessEquals(screen.height - navBar, epsilon: 0.5));
    });

    testWidgets('com barra no rodapé, é ela que recebe o recuo', (
      tester,
    ) async {
      await pumpScaffold(
        tester,
        body: const SizedBox.expand(key: Key('corpo')),
        bottomNavigationBar: const SizedBox(
          key: Key('rodape'),
          height: 60,
          width: double.infinity,
        ),
      );

      // O rodapé encosta na barra; quem sobe é o conteúdo dele.
      final rodape = tester.getBottomLeft(find.byKey(const Key('rodape'))).dy;
      expect(
        rodape,
        moreOrLessEquals(screen.height - navBar, epsilon: 0.5),
      );

      // E o corpo para onde o rodapé começa, sem recuo duplicado.
      final corpo = tester.getBottomLeft(find.byKey(const Key('corpo'))).dy;
      expect(corpo, lessThan(rodape));
    });
  });
}
