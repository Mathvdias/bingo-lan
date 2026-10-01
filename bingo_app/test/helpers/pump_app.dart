import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_theme.dart';

/// Monta [child] dentro de um MaterialApp com o tema real (fonte do sistema),
/// l10n em [locale], tela de celular pequeno (360x740 @1x) e escala de texto
/// [textScale]. Overflow de RenderFlex derruba o teste.
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  double textScale = 1.0,
  Locale locale = const Locale('pt'),
  Size size = const Size(360, 740),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: testBingoTheme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, app) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: app!,
      ),
      home: Scaffold(body: child),
    ),
  );
  await tester.pumpAndSettle();
}
