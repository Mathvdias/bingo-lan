import 'package:get_it/get_it.dart';

import '../drivers/i_config_driver.dart';
import '../drivers/i_game_connection.dart';
import '../drivers/i_network_info_driver.dart';
import '../drivers/i_payment_driver.dart';
import '../drivers/i_uuid_driver.dart';
import '../drivers/local_shelf_game_connection.dart';
import '../drivers/network_info_driver.dart';
import '../drivers/payment_driver.dart';
import '../drivers/remote_config_driver.dart';
import '../drivers/uuid_driver.dart';
import '../logic/access_control_service.dart';

/// Ponto de entrada do SDK do Bingo.
///
/// Registra drivers e serviços no GetIt. Não configura SDKs de terceiros com
/// chaves: o RevenueCat é configurado uma única vez pelo app.
class BingoSDK {
  /// Inicializa o SDK. Deve ser chamado uma vez na abertura do app.
  static Future<void> initialize() async {
    final getIt = GetIt.instance;

    // config
    getIt.registerSingleton<IConfigDriver>(RemoteConfigDriver());

    // payment (somente leitura de CustomerInfo)
    getIt.registerSingleton<IPaymentDriver>(PaymentDriver());

    // network & uuid
    getIt.registerSingleton<INetworkInfoDriver>(NetworkInfoDriver());
    getIt.registerSingleton<IUUIDDriver>(UUIDDriver());

    await getIt<IPaymentDriver>().init();

    getIt.registerSingleton<AccessControlService>(
      AccessControlService(
        config: getIt<IConfigDriver>(),
        payment: getIt<IPaymentDriver>(),
      ),
    );

    getIt.registerSingleton<IGameConnection>(
      LocalShelfGameConnection(
        accessControl: getIt<AccessControlService>(),
        configDriver: getIt<IConfigDriver>(),
      ),
    );
  }
}
