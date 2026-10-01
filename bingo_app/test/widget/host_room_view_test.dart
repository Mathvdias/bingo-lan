import 'dart:math';

import 'package:bingo_app/features/host/host_room_view_model.dart';
import 'package:bingo_app/features/host/widgets/host_room_view.dart';
import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_drivers.dart';
import '../helpers/test_theme.dart';
import '../unit/fake_game_connection.dart';

const _screen = Size(360, 640);
final _viewport = Offset.zero & _screen;

/// Monta a sala do host num celular pequeno (360x640 dp) com escala de texto
/// [textScale], barra de gestos de [bottomPadding] dp, um jogador já
/// conectado e o interruptor do globo automático visível (pior caso de
/// altura do rodapé).
Future<(HostRoomViewModel, FakeGameConnection)> _pumpView(
  WidgetTester tester, {
  double textScale = 1.0,
  double bottomPadding = 0,
}) async {
  tester.view.physicalSize = _screen;
  tester.view.devicePixelRatio = 1.0;
  tester.view.padding = FakeViewPadding(bottom: bottomPadding);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);

  final connection = FakeGameConnection(connectedPlayers: const ['Ana']);
  final config = FakeConfigDriver();
  final viewModel = HostRoomViewModel(
    gameConnection: connection,
    accessControlService: AccessControlService(
      config: config,
      payment: FakePaymentDriver(),
    ),
    configDriver: config,
    random: Random(7),
  );
  // LIFO: o VM (que chama disconnect) sai antes da conexão fechar.
  addTearDown(connection.dispose);
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
        builder: (context, _) => HostRoomView(
          viewModel: viewModel,
          onExit: () {},
          onEndRoom: () {},
          maxPlayers: 10,
          purchasesEnabled: true,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (viewModel, connection);
}

void _expectInsideViewport(WidgetTester tester, Finder finder, String what) {
  final rect = tester.getRect(finder);
  expect(
    _viewport.contains(rect.topLeft) && _viewport.contains(rect.bottomRight),
    isTrue,
    reason: '$what $rect fora da tela $_viewport',
  );
}

void main() {
  group('HostRoomView em 360x640', () {
    final draw = find.byKey(const Key('host_draw_button'));
    final tabVirtual = find.byKey(const Key('host_tab_virtual'));
    final tabManual = find.byKey(const Key('host_tab_manual'));

    for (final scale in [1.0, 1.3]) {
      testWidgets(
        'SORTEAR e as abas ficam na tela sem rolar, vazio e com bolas '
        '(escala $scale)',
        (tester) async {
          final (vm, _) = await _pumpView(tester, textScale: scale);
          expect(tester.takeException(), isNull);

          // Estado vazio.
          expect(find.byKey(const Key('host_empty_state')), findsOneWidget);
          _expectInsideViewport(tester, draw, 'SORTEAR (vazio)');
          _expectInsideViewport(tester, tabVirtual, 'aba Virtual');
          _expectInsideViewport(tester, tabManual, 'aba Manual');
          expect(find.text('Virtual'), findsOneWidget);
          expect(find.text('Manual'), findsOneWidget);
          final emptyRect = tester.getRect(draw);
          // Botão com altura de botão, não esticado.
          expect(emptyRect.height, lessThan(120));
          expect(emptyRect.width, 360 - 32);

          // Jogador que entrou antes da tela abrir já conta.
          expect(find.text('1/10'), findsOneWidget);

          // Toque chega no botão (nada por cima) e sorteia.
          await tester.tap(draw);
          await tester.pumpAndSettle();
          expect(vm.drawnNumbers.length, 1);

          await vm.drawRandomNumber();
          await vm.drawRandomNumber();
          await tester.pumpAndSettle();
          expect(vm.drawnNumbers.length, 3);

          // Com bolas: continua no mesmo lugar, inteiro na tela.
          expect(find.byKey(const Key('host_last_number')), findsOneWidget);
          expect(find.byKey(const Key('host_history')), findsOneWidget);
          _expectInsideViewport(tester, draw, 'SORTEAR (3 bolas)');
          _expectInsideViewport(tester, tabVirtual, 'aba Virtual');
          _expectInsideViewport(tester, tabManual, 'aba Manual');
          expect(tester.getRect(draw), equals(emptyRect));
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('respeita a barra de gestos do sistema', (tester) async {
      await _pumpView(tester, bottomPadding: 24);
      final rect = tester.getRect(draw);
      expect(rect.bottom, lessThanOrEqualTo(_screen.height - 24 - 16));
      _expectInsideViewport(tester, draw, 'SORTEAR');
    });

    testWidgets('aba Manual mostra o campo no rodapé, sem mover o rodapé', (
      tester,
    ) async {
      await _pumpView(tester);
      final footer = find.byKey(const Key('host_draw_footer'));
      final before = tester.getRect(footer);

      await tester.tap(tabManual);
      await tester.pumpAndSettle();

      final field = find.byKey(const Key('host_manual_field'));
      expect(field.hitTestable(), findsOneWidget);
      _expectInsideViewport(tester, field, 'campo manual');
      expect(tester.getRect(footer), equals(before));
      expect(tester.takeException(), isNull);
    });

    testWidgets('bingo validado: camada cobre tudo e o rodapé sai', (
      tester,
    ) async {
      final (vm, connection) = await _pumpView(tester);
      const cardId = 77;
      for (final n in BingoCard(id: cardId).matrix.sublist(0, 5)) {
        await vm.drawManualNumber(n);
      }
      connection.emit(
        ShoutBingoEvent(playerId: 'p-1', cardId: cardId, playerName: 'Ana'),
      );
      await tester.pumpAndSettle();
      await vm.validateClaim(vm.bingoClaims.single);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('host_winner_overlay')), findsOneWidget);
      expect(find.byKey(const Key('host_draw_footer')), findsNothing);
      expect(draw, findsNothing);
    });
  });
}
