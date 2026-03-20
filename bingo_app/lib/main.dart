import 'package:bingo_app/flavors/app_config.dart';
import 'package:bingo_app/main_common.dart';

void main() {
  final prodConfig = AppConfig(
    flavor: Flavor.prod,
    appTitle: 'Bingo',
    apiBaseUrl: 'https://api.bingo.com',
  );

  mainCommon(prodConfig);
}