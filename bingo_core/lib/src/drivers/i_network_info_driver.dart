abstract class INetworkInfoDriver {
  Future<String?> getWifiIP();
  Future<String?> getWifiName();
}
