import 'package:bingo_app/features/player/player_game_args.dart';
import 'package:bingo_app/features/player/player_game_view_model.dart';
import 'package:bingo_app/features/player/widgets/player_game_view.dart';
import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/ui/widgets/card_cell.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_theme.dart';
import '../unit/fake_game_connection.dart';

const _screen = Size(360, 640);

/// Monta a tela do jogador num celular pequeno (360x640 dp) com escala de
/// texto [textScale] e barra de gestos de [bottomPadding] dp.
Future<FakeGameConnection> _pumpView(
  WidgetTester tester, {
  double textScale = 1.0,
  double bottomPadding = 0,
  GameConnectionState connection = GameConnectionState.connected,
}) async {
  tester.view.physicalSize = _screen;
  tester.view.devicePixelRatio = 1.0;
  tester.view.padding = FakeViewPadding(bottom: bottomPadding);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);

  final fake = FakeGameConnection(initialState: connection);
  addTearDown(fake.dispose);
  final viewModel = PlayerGameViewModel(
    args: const PlayerGameArgs(
      cardId: 7,
      playerName: 'Ana',
      playerId: 'p1',
      initialDrawnNumbers: [12, 33, 60],
    ),
    gameConnection: fake,
  );
  addTearDown(viewModel.dispose);

  await tester.pumpWidget(
    MaterialApp(
      theme: testBingoTheme,
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, app) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: app!,
      ),
      home: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) =>
            PlayerGameView(viewModel: viewModel, onExit: () {}, onLeave: () {}),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return fake;
}

void main() {
  group('PlayerGameView em 360x640', () {
    final viewport = Offset.zero & _screen;
    final shout = find.byKey(const Key('player_shout_button'));

    for (final scale in [1.0, 1.3]) {
      testWidgets('GRITAR BINGO! inteiro na tela sem rolar (escala $scale)', (
        tester,
      ) async {
        await _pumpView(tester, textScale: scale);
        expect(tester.takeException(), isNull);

        expect(shout, findsOneWidget);
        final rect = tester.getRect(shout);
        // Botão com altura de botão (não esticado até o fim da tela).
        expect(rect.height, lessThan(120));
        expect(rect.width, 360 - 32);
        expect(
          viewport.contains(rect.topLeft) &&
              viewport.contains(rect.bottomRight),
          isTrue,
          reason: 'botão $rect fora da tela $viewport',
        );
        // Nada por cima: toque chega no botão.
        expect(shout.hitTestable(), findsOneWidget);
        // A cartela continua inteira.
        expect(find.text('LIVRE'), findsOneWidget);
        expect(find.byType(CardCell), findsNWidgets(25));
      });
    }

    bool inside(Rect rect) =>
        viewport.contains(rect.topLeft) && viewport.contains(rect.bottomRight);

    testWidgets('faixa de status, cabeçalho e as 25 células cabem sem rolar', (
      tester,
    ) async {
      final fake = await _pumpView(tester);
      expect(tester.takeException(), isNull);

      final status = find.byKey(const Key('player_status_card'));
      expect(inside(tester.getRect(status)), isTrue, reason: 'status fora');
      expect(find.text('3/75 sorteados'), findsOneWidget);
      expect(find.byKey(const Key('player_last_called')), findsOneWidget);
      expect(find.text('B'), findsOneWidget);

      final cells = find.byType(CardCell);
      expect(cells, findsNWidgets(25));
      final shoutRect = tester.getRect(shout);
      for (var i = 0; i < 25; i++) {
        final rect = tester.getRect(cells.at(i));
        expect(inside(rect), isTrue, reason: 'célula $i $rect fora da tela');
        expect(
          rect.bottom,
          lessThanOrEqualTo(shoutRect.top),
          reason: 'célula $i $rect sob o rodapé $shoutRect',
        );
        // Alvo de toque confortável.
        expect(rect.width, greaterThanOrEqualTo(44));
        expect(rect.height, closeTo(rect.width, 0.01));
      }

      // Toque numa célula cantada marca (nada por cima).
      final card = BingoCard(id: 7);
      final called = card.matrix.firstWhere((n) => n != 0 && n != 12);
      fake.emit(NumberDrawnEvent(number: called));
      await tester.pumpAndSettle();
      await tester.tap(find.text('$called'));
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel('${BingoCard.label(called)}, marcado'),
        findsOneWidget,
      );
    });

    testWidgets('a 1.3x nada estoura e as células não ficam menores que 44', (
      tester,
    ) async {
      await _pumpView(tester, textScale: 1.3);
      expect(tester.takeException(), isNull);

      final cells = find.byType(CardCell);
      expect(cells, findsNWidgets(25));
      for (var i = 0; i < 25; i++) {
        expect(tester.getRect(cells.at(i)).width, greaterThanOrEqualTo(44));
      }
      expect(inside(tester.getRect(shout)), isTrue);
      expect(
        inside(tester.getRect(find.byKey(const Key('player_status_card')))),
        isTrue,
      );
    });

    testWidgets(
      'a 1.3x com aviso de conexão a cartela rola até a última linha',
      (tester) async {
        // disconnected: o aviso mostra um ícone (o spinner de "reconectando"
        // nunca assenta no pumpAndSettle).
        await _pumpView(
          tester,
          textScale: 1.3,
          connection: GameConnectionState.disconnected,
        );
        expect(tester.takeException(), isNull);
        expect(
          find.byKey(const Key('player_connection_banner')),
          findsOneWidget,
        );
        final cells = find.byType(CardCell);
        expect(cells, findsNWidgets(25));

        final scroll = find.byKey(const Key('player_card_scroll'));
        await tester.drag(scroll, const Offset(0, -400));
        await tester.pumpAndSettle();
        final last = tester.getRect(cells.at(24));
        expect(last.bottom, lessThanOrEqualTo(tester.getRect(shout).top));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('respeita a barra de gestos do sistema', (tester) async {
      await _pumpView(tester, bottomPadding: 24);
      final rect = tester.getRect(shout);
      expect(rect.bottom, lessThanOrEqualTo(_screen.height - 24 - 16));
    });

    testWidgets('com aviso de conexão a 1.3x o botão continua visível', (
      tester,
    ) async {
      await _pumpView(
        tester,
        textScale: 1.3,
        connection: GameConnectionState.disconnected,
      );
      expect(find.byKey(const Key('player_connection_banner')), findsOneWidget);
      final rect = tester.getRect(shout);
      expect(viewport.contains(rect.bottomRight), isTrue, reason: '$rect');
      expect(tester.takeException(), isNull);
    });

    testWidgets('sala encerrada: camada cobre tudo e o rodapé sai', (
      tester,
    ) async {
      final fake = await _pumpView(tester);
      // Simula ROOM_CLOSED vindo da conexão.
      fake.setState(GameConnectionState.roomClosed);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('player_room_closed_overlay')),
        findsOneWidget,
      );
      expect(shout, findsNothing);
    });
  });
}
