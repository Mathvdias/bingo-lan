import 'package:bingo_core/src/drivers/i_network_info_driver.dart';
import 'package:network_info_plus/network_info_plus.dart';

class NetworkInfoDriver implements INetworkInfoDriver {
  @override
  Future<String?> getWifiIP() async {
    final ip = await NetworkInfo().getWifiIP();
    // Android devolve 0.0.0.0 sem Wi-Fi em alguns aparelhos.
    if (ip == null || ip.isEmpty || ip == '0.0.0.0') return null;
    return ip;
  }

  @override
  Future<String?> getWifiSubnetMask() async {
    try {
      final mask = await NetworkInfo().getWifiSubmask();
      if (mask == null || mask.isEmpty || mask == '0.0.0.0') return null;
      return mask;
    } catch (_) {
      return null;
    }
  }
}
