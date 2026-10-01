import 'dart:async';
import 'dart:io';

/// Resultado de uma sondagem TCP ao host da sala.
enum HostProbeResult {
  /// Alguém atende em `ip:porta`: o host está acessível.
  reachable,

  /// O aparelho do host respondeu, mas recusou a porta: a sala foi fechada
  /// ou o convite é de uma sala antiga.
  refused,

  /// Nada respondeu no tempo limite: outra rede, isolamento de clientes
  /// (rede de convidados / condomínio) ou host sem Wi-Fi.
  unreachable,
}

/// Verifica se o host do convite responde antes de abrir o WebSocket, para
/// separar "não alcancei o anfitrião" de "o anfitrião recusou".
abstract class IHostReachability {
  Future<HostProbeResult> probe(
    String ip,
    int port, {
    Duration timeout = const Duration(seconds: 3),
  });
}

/// Sondagem real: abre e fecha uma conexão TCP com o host.
class TcpHostReachability implements IHostReachability {
  const TcpHostReachability();

  @override
  Future<HostProbeResult> probe(
    String ip,
    int port, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    Socket? socket;
    try {
      socket = await Socket.connect(ip, port, timeout: timeout);
      return HostProbeResult.reachable;
    } on SocketException catch (e) {
      // ECONNREFUSED: há rota até o aparelho, mas nada escuta na porta.
      final code = e.osError?.errorCode;
      final refused =
          code == 61 || code == 111 || code == 10061 || code == 10054;
      return refused ? HostProbeResult.refused : HostProbeResult.unreachable;
    } on TimeoutException {
      return HostProbeResult.unreachable;
    } catch (_) {
      return HostProbeResult.unreachable;
    } finally {
      socket?.destroy();
    }
  }
}
