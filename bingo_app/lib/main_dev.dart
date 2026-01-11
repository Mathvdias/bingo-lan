import 'package:bingo_app/flavors/app_config.dart';
import 'package:bingo_app/main.dart';

void main() {
  final devConfig = AppConfig(
    flavor: Flavor.dev,
    appTitle: 'Bingo Lucca (Dev)',
    apiBaseUrl: 'https://dev-api.bingolucca.com',
  );

  mainCommon(devConfig);
}
