import 'package:bingo_app/features/player/player_game_args.dart';
import 'package:bingo_app/features/player/player_game_view_model.dart';
import 'package:bingo_app/features/player/widgets/player_game_view.dart';
import 'package:bingo_app/l10n/app_localizations.dart';
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
        // A cartela continua inteira (rolável acima do rodapé).
        expect(find.text('LIVRE'), findsOneWidget);
      });
    }

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
