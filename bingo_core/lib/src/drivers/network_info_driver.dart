import 'package:bingo_core/src/drivers/i_network_info_driver.dart';
import 'package:network_info_plus/network_info_plus.dart';

class NetworkInfoDriver implements INetworkInfoDriver {
  @override
  Future<String?> getWifiIP() {
    return NetworkInfo().getWifiIP();
  }

  @override
  Future<String?> getWifiName() {
    return NetworkInfo().getWifiName();
  }
}
