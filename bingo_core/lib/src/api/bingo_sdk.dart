import 'package:get_it/get_it.dart';

import '../drivers/i_config_driver.dart';
import '../drivers/i_game_connection.dart';
import '../drivers/i_network_info_driver.dart'; // New import
import '../drivers/i_payment_driver.dart';
import '../drivers/i_uuid_driver.dart'; // New import
import '../drivers/local_shelf_game_connection.dart';
import '../drivers/network_info_driver.dart'; // New import
import '../drivers/uuid_driver.dart'; // New import
import '../logic/access_control_service.dart';

import '../drivers/payment_driver.dart'; // New import
import '../drivers/remote_config_driver.dart'; // New import

// ... Placeholders removed ...

/// The main entry point for the Bingo SDK.
/// It handles the initialization of all necessary drivers and services.
class BingoSDK {
  /// Initializes the SDK.
  ///
  /// This method should be called once at app startup.
  /// It sets up the dependency injection container (GetIt) and registers
  /// the necessary service drivers.
  ///
  /// The [supabaseUrl], [supabaseKey], and [revenueCatKey] are placeholders
  /// for the actual keys required by the real implementations.
  static Future<void> initialize({
    required String supabaseUrl,
    required String supabaseKey,
    required String revenueCatKey,
  }) async {
    final getIt = GetIt.instance;

    // Register drivers
    // Note: In a real app, you might lazily initialize some of these or handle errors if they fail.

    // config
    getIt.registerSingleton<IConfigDriver>(RemoteConfigDriver());

    // payment
    getIt.registerSingleton<IPaymentDriver>(PaymentDriver(revenueCatKey));

    // connection
    // For now we default to LocalShelf. If we want to support Online, we might need a Factory or switch implementation based on setup.
    // However, IGameConnection is usually a singleton per session.
    // If the app supports switching modes, we might need to register it as a LazySingleton or just re-register it?
    // For simplicity, we register the Local one as default.
    getIt.registerSingleton<IGameConnection>(LocalShelfGameConnection());

    // network & uuid
    getIt.registerSingleton<INetworkInfoDriver>(NetworkInfoDriver());
    getIt.registerSingleton<IUUIDDriver>(UUIDDriver());

    // Initialize the payment driver
    await getIt<IPaymentDriver>().init();

    // Register the AccessControlService which depends on the drivers
    getIt.registerSingleton<AccessControlService>(
      AccessControlService(
        config: getIt<IConfigDriver>(),
        payment: getIt<IPaymentDriver>(),
      ),
    );
  }
}
