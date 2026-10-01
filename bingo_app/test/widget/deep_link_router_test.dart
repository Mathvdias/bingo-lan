import 'package:bingo_app/shared/router.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Convite de teste; o `data` do link é o Base64 de [BingoInvite.toBase64].
const _invite = BingoInvite(
  ip: '192.168.0.10',
  port: 4242,
  token: 'jwt-token',
  roomName: 'Sala teste',
);

/// Router com o mesmo [deepLinkRedirect] e os mesmos caminhos do app, mas com
/// telas de stub: o [router] real puxa Firebase (observer de analytics,
/// Remote Config do lobby) e não pode ser montado em teste de widget.
GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: '/lobby',
    redirect: deepLinkRedirect,
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/lobby'),
      GoRoute(path: '/splash', redirect: (context, state) => '/lobby'),
      GoRoute(
        path: '/lobby',
        builder: (context, state) =>
            const Text('lobby', key: Key('stub_lobby')),
      ),
      GoRoute(
        path: joinPath,
        builder: (context, state) => Text(
          'join:${state.uri.queryParameters[BingoInvite.dataParam] ?? ''}',
          key: const Key('stub_join'),
        ),
      ),
      GoRoute(
        path: '/player/scan',
        builder: (context, state) => Text(
          state.uri.queryParameters[BingoInvite.dataParam] ?? '',
          key: const Key('stub_scan'),
        ),
      ),
    ],
  );
}

Future<GoRouter> _pumpRouter(WidgetTester tester) async {
  final router = _buildRouter();
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('stub_lobby')), findsOneWidget);
  return router;
}

void main() {
  group('App Link /join?data=', () {
    testWidgets('https://.../join?data=<base64> chega ao scan com o convite', (
      tester,
    ) async {
      final router = await _pumpRouter(tester);
      final data = _invite.toBase64();

      // O go_router recebe o App Link https como o caminho `/join?data=`.
      final uri = Uri.parse(_invite.toWebLink());
      expect(uri.path, joinPath);
      router.go('${uri.path}?${uri.query}');
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/player/scan');
      expect(router.state.uri.queryParameters[BingoInvite.dataParam], data);
      final scan = tester.widget<Text>(find.byKey(const Key('stub_scan')));
      expect(scan.data, data);
      expect(BingoInvite.parse(scan.data!)?.roomName, _invite.roomName);
    });

    testWidgets('router.go(\'/join?data=<base64>\') com a forma literal', (
      tester,
    ) async {
      final router = await _pumpRouter(tester);
      router.go('/join?data=${_invite.toBase64()}');
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/player/scan');
      expect(find.byKey(const Key('stub_scan')), findsOneWidget);
      expect(find.byKey(const Key('stub_join')), findsNothing);
    });

    testWidgets(
      'deep link bingo://join chega como `?data=` e também redireciona',
      (tester) async {
        final router = await _pumpRouter(tester);
        router.go('/?data=${_invite.toBase64()}');
        await tester.pumpAndSettle();

        expect(router.state.uri.path, '/player/scan');
        expect(
          router.state.uri.queryParameters[BingoInvite.dataParam],
          _invite.toBase64(),
        );
      },
    );

    testWidgets('/join sem data abre o leitor em vez de redirecionar', (
      tester,
    ) async {
      final router = await _pumpRouter(tester);
      router.go('/join');
      await tester.pumpAndSettle();

      expect(router.state.uri.path, joinPath);
      expect(find.byKey(const Key('stub_join')), findsOneWidget);
    });

    testWidgets('/splash segue válido e cai no lobby', (tester) async {
      final router = await _pumpRouter(tester);
      router.go('/splash');
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/lobby');
      expect(find.byKey(const Key('stub_lobby')), findsOneWidget);
    });
  });

  group('appRoutes', () {
    test('tem /join, /player/scan e os redirecionamentos de / e /splash', () {
      final paths = appRoutes.whereType<GoRoute>().map((r) => r.path).toList();
      expect(
        paths,
        containsAll(<String>[
          '/',
          '/splash',
          '/lobby',
          joinPath,
          '/player/scan',
        ]),
      );
      // Nenhuma rota de splash Flutter: / e /splash só redirecionam.
      for (final path in ['/', '/splash']) {
        final route = appRoutes.whereType<GoRoute>().firstWhere(
          (r) => r.path == path,
        );
        expect(route.builder, isNull, reason: '$path não deve ter tela');
        expect(route.redirect, isNotNull, reason: '$path deve redirecionar');
      }
    });
  });
}
