import 'dart:io';

import 'package:bingo_core/bingo_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const probe = TcpHostReachability();

  test('porta com servidor escutando é alcançável', () async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(server.close);
    server.listen((socket) => socket.destroy());

    final result = await probe.probe('127.0.0.1', server.port);
    expect(result, HostProbeResult.reachable);
  });

  test('porta fechada no mesmo aparelho é recusada', () async {
    // Reserva uma porta e libera: nada escuta nela em seguida.
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final port = server.port;
    await server.close();

    final result = await probe.probe('127.0.0.1', port);
    expect(result, HostProbeResult.refused);
  });

  test('endereço sem rota estoura o tempo e fica inalcançável', () async {
    // 192.0.2.0/24 é reservado para documentação (RFC 5737): nunca responde.
    final result = await probe.probe(
      '192.0.2.1',
      4242,
      timeout: const Duration(milliseconds: 300),
    );
    expect(result, HostProbeResult.unreachable);
  });
}
