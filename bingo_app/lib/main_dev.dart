import 'package:bingo_app/flavors/app_config.dart';
import 'package:bingo_app/main_common.dart';

Future<void> main() async {
  final devConfig = AppConfig(
    flavor: Flavor.dev,
    appTitle: 'Bingo (Dev)',
    apiBaseUrl: 'https://dev-api.bingo.com',
  );

  await mainCommon(devConfig);
}
