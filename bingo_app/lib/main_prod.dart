import 'package:bingo_app/flavors/app_config.dart';
import 'package:bingo_app/main_common.dart';

Future<void> main() async {
  final prodConfig = AppConfig(
    flavor: Flavor.prod,
    appTitle: 'Bingo',
    apiBaseUrl: 'https://api.bingo.com',
  );

  await mainCommon(prodConfig);
}
