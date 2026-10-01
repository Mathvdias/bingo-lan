import 'package:bingo_app/flavors/app_config.dart';
import 'package:bingo_app/main_common.dart';

/// Entrada do flavor alpha (teste fechado da Play). Igual à prod em Firebase,
/// RevenueCat, anúncios e validação de chaves; só liga as ferramentas de
/// depuração (`AppConfig.hasDebugTools`).
Future<void> main() async {
  final alphaConfig = AppConfig(
    flavor: Flavor.alpha,
    appTitle: 'Bingo β',
    apiBaseUrl: 'https://api.bingo.com',
  );

  await mainCommon(alphaConfig);
}
