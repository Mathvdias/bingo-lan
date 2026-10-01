import 'package:bingo_core/bingo_core.dart';

/// Remote Config falso: tudo desligado/zero, sem Firebase.
class FakeConfigDriver implements IConfigDriver {
  final Map<String, Object> values = {};
  int fetches = 0;

  @override
  Future<void> fetchAndActivate() async => fetches++;

  @override
  bool getBool(String key) => values[key] as bool? ?? false;

  @override
  int getInt(String key) => values[key] as int? ?? 0;

  @override
  String getString(String key) => values[key] as String? ?? '';
}

/// Pagamentos falsos: usuário grátis, sem RevenueCat.
class FakePaymentDriver implements IPaymentDriver {
  bool pro = false;

  @override
  Future<bool> get isProUser async => pro;

  @override
  Future<void> init() async {}

  @override
  Future<void> purchasePro() async {}

  @override
  Future<void> restorePurchases() async {}
}

/// Rede falsa: IP e máscara configuráveis, sem plugin.
class FakeNetworkInfoDriver implements INetworkInfoDriver {
  String? ip;
  String? mask;
  Object? ipError;
  int ipReads = 0;

  FakeNetworkInfoDriver({this.ip = '192.168.0.20', this.mask});

  @override
  Future<String?> getWifiIP() async {
    ipReads++;
    if (ipError != null) throw ipError!;
    return ip;
  }

  @override
  Future<String?> getWifiSubnetMask() async => mask;
}

/// Sondagem falsa do host: devolve o resultado configurado.
class FakeHostReachability implements IHostReachability {
  HostProbeResult result;
  final List<(String, int)> probes = [];

  FakeHostReachability([this.result = HostProbeResult.reachable]);

  @override
  Future<HostProbeResult> probe(
    String ip,
    int port, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    probes.add((ip, port));
    return result;
  }
}
