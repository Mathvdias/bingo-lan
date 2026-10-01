import 'package:bingo_app/features/about/about_screen.dart';
import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/providers/locale_provider.dart';
import 'package:bingo_app/shared/router.dart' show debugFlagsPath;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_theme.dart';

/// Relógio controlável: `DateTime.now()` não anda com `tester.pump`.
DateTime _now = DateTime(2026, 10, 1, 12);

/// Monta o "Sobre" num router com a rota de flags em stub.
Future<GoRouter> _pumpAbout(
  WidgetTester tester, {
  required bool debugTools,
}) async {
  tester.view.physicalSize = const Size(360, 740);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final router = GoRouter(
    initialLocation: '/about',
    routes: [
      GoRoute(
        path: '/about',
        builder: (context, state) =>
            AboutScreen(debugTools: debugTools, now: () => _now),
      ),
      GoRoute(
        path: debugFlagsPath,
        builder: (context, state) =>
            const Scaffold(body: Text('flags', key: Key('stub_flags'))),
      ),
    ],
  );
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: MaterialApp.router(
        theme: testBingoTheme,
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

Future<void> _tapVersion(WidgetTester tester, int times) async {
  final row = find.byKey(const Key('about_version_row'));
  await tester.scrollUntilVisible(row, 200);
  for (var i = 0; i < times; i++) {
    await tester.tap(row);
    await tester.pump();
  }
}

void main() {
  setUp(() {
    _now = DateTime(2026, 10, 1, 12);
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'Bingo',
      packageName: 'com.nightstudios.bingo',
      version: '1.0.5',
      buildNumber: '42',
      buildSignature: '',
    );
  });

  group('AboutScreen', () {
    testWidgets('mostra a versão do app', (tester) async {
      await _pumpAbout(tester, debugTools: true);
      await tester.scrollUntilVisible(
        find.byKey(const Key('about_version_text')),
        200,
      );
      expect(find.text('Versão 1.0.5 (42)'), findsOneWidget);
    });

    testWidgets('5 toques na versão abrem /debug/flags com dica nos 3º e 4º', (
      tester,
    ) async {
      final router = await _pumpAbout(tester, debugTools: true);

      await _tapVersion(tester, 2);
      expect(find.byKey(const Key('about_debug_hint')), findsNothing);

      await _tapVersion(tester, 1);
      await tester.pump();
      expect(find.text('mais 2 toques…'), findsOneWidget);

      await _tapVersion(tester, 1);
      await tester.pump();
      expect(find.text('mais 1 toque…'), findsOneWidget);

      await _tapVersion(tester, 1);
      await tester.pumpAndSettle();
      expect(router.state.uri.path, debugFlagsPath);
      expect(find.byKey(const Key('stub_flags')), findsOneWidget);
    });

    testWidgets('toques lentos (fora da janela de 3 s) não abrem', (
      tester,
    ) async {
      final router = await _pumpAbout(tester, debugTools: true);

      await _tapVersion(tester, 4);
      // Janela expirada: a contagem recomeça do zero.
      _now = _now.add(const Duration(seconds: 4));
      await _tapVersion(tester, 1);
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/about');
    });

    testWidgets('em prod (sem ferramentas) os toques não fazem nada', (
      tester,
    ) async {
      final router = await _pumpAbout(tester, debugTools: false);

      await _tapVersion(tester, 5);
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/about');
      expect(find.byKey(const Key('about_debug_hint')), findsNothing);
    });
  });
}
