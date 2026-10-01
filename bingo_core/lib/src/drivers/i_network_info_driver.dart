/// Informações da rede Wi-Fi do aparelho.
///
/// Só expõe o que funciona sem permissão de localização no Android 10+
/// (o nome da rede/SSID exigiria ACCESS_FINE_LOCATION e GPS ligado).
abstract class INetworkInfoDriver {
  /// IPv4 do aparelho na rede Wi-Fi, ou `null` quando não está no Wi-Fi.
  Future<String?> getWifiIP();

  /// Máscara de sub-rede do Wi-Fi (ex.: 255.255.255.0), ou `null`.
  Future<String?> getWifiSubnetMask();
}
