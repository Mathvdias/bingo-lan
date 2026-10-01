/// Comparação de sub-rede IPv4 sem depender de permissão de localização.
///
/// Serve para explicar ao jogador por que o anfitrião não respondeu: se os
/// dois IPs não estão na mesma sub-rede, ele quase certamente está em outra
/// rede Wi-Fi (ou nos dados móveis).
class LanSubnet {
  LanSubnet._();

  /// Máscara assumida quando o sistema não informa a real. Cobre a quase
  /// totalidade dos roteadores domésticos e hotspots de celular.
  static const String defaultMask = '255.255.255.0';

  /// `true` quando [a] e [b] são IPv4 válidos e pertencem à mesma sub-rede
  /// segundo [mask] (ou [defaultMask] quando [mask] é nula/inválida).
  /// Retorna `null` quando algum IP não pode ser interpretado.
  static bool? sameSubnet(String? a, String? b, {String? mask}) {
    final ia = _parse(a);
    final ib = _parse(b);
    if (ia == null || ib == null) return null;
    final m = _parse(mask) ?? _parse(defaultMask)!;
    return (ia & m) == (ib & m);
  }

  static int? _parse(String? ip) {
    if (ip == null) return null;
    final parts = ip.trim().split('.');
    if (parts.length != 4) return null;
    var value = 0;
    for (final part in parts) {
      final n = int.tryParse(part);
      if (n == null || n < 0 || n > 255) return null;
      value = (value << 8) | n;
    }
    return value;
  }
}
