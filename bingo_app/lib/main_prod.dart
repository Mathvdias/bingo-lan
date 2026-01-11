import 'package:bingo_app/flavors/app_config.dart';
import 'package:bingo_app/main.dart';

void main() {
  final prodConfig = AppConfig(
    flavor: Flavor.prod,
    appTitle: 'Bingo Lucca',
    apiBaseUrl: 'https://api.bingolucca.com',
  );

  mainCommon(prodConfig);
}
