import 'package:bingo_app/features/host/host_invite_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_game_connection.dart';

void main() {
  group('HostInviteViewModel', () {
    test('parte da lista atual da conexão e acompanha mudanças', () async {
      final connection = FakeGameConnection(connectedPlayers: const ['Ana']);
      addTearDown(connection.dispose);
      final vm = HostInviteViewModel(gameConnection: connection);
      addTearDown(vm.dispose);

      expect(vm.connectedPlayers, ['Ana']);

      connection.emitPlayers(const ['Ana', 'Bob']);
      await pumpEventQueue();
      expect(vm.connectedPlayers, ['Ana', 'Bob']);
    });

    test('leaveRoom derruba a sala', () async {
      final connection = FakeGameConnection();
      addTearDown(connection.dispose);
      final vm = HostInviteViewModel(gameConnection: connection);
      addTearDown(vm.dispose);

      await vm.leaveRoom();
      expect(connection.disconnectCalls, 1);
    });
  });
}
