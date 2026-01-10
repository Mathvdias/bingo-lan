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

// This is a placeholder implementation for the IConfigDriver.
// A real implementation would use a service like Firebase Remote Config.
class _PlaceholderConfigDriver implements IConfigDriver {
  @override
  Future<void> fetchAndActivate() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  bool getBool(String key) {
    return false;
  }

  @override
  int getInt(String key) {
    if (key == 'max_free_online_users') {
      return 10;
    }
    return 0;
  }
}

// This is a placeholder implementation for the IPaymentDriver.
// A real implementation would use a service like RevenueCat.
class _PlaceholderPaymentDriver implements IPaymentDriver {
  @override
  Future<void> init() async {}

  @override
  Future<bool> get isProUser async {
    return false;
  }

  @override
  Future<void> purchasePro() async {}

  @override
  Future<void> restorePurchases() async {}
}


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

    // Register drivers with placeholder implementations for now.
    getIt.registerSingleton<IConfigDriver>(_PlaceholderConfigDriver());
    getIt.registerSingleton<IPaymentDriver>(_PlaceholderPaymentDriver());
    getIt.registerSingleton<IGameConnection>(LocalShelfGameConnection());
    getIt.registerSingleton<INetworkInfoDriver>(NetworkInfoDriver()); // New registration
    getIt.registerSingleton<IUUIDDriver>(UUIDDriver()); // New registration

    // Initialize the payment driver
    await getIt<IPaymentDriver>().init();

    // Register the AccessControlService which depends on the drivers
    getIt.registerSingleton<AccessControlService>(
      AccessControlService(
        config: getIt<IConfigDriver>(),
        payment: getIt<IPaymentDriver>(),
      ),
    );

    // TODO: Initialize and register other drivers (Audio) here.
  }
}
