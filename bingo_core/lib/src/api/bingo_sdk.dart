import 'package:get_it/get_it.dart';

import '../drivers/i_config_driver.dart';
import '../drivers/i_payment_driver.dart';
import '../logic/access_control_service.dart';

// This is a placeholder implementation for the IConfigDriver.
// A real implementation would use a service like Firebase Remote Config.
class _PlaceholderConfigDriver implements IConfigDriver {
  @override
  Future<void> fetchAndActivate() async {
    // In a real implementation, this would fetch data from a remote service.
    print("PlaceholderConfigDriver: fetchAndActivate called");
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  bool getBool(String key) {
    // Defaulting to 'false' for paid features, as per the doc.
    // This makes features free by default in this placeholder.
    print("PlaceholderConfigDriver: getBool for '$key' -> returning false");
    return false;
  }

  @override
  int getInt(String key) {
    // Defaulting max_free_online_users to 10, as per the doc.
    if (key == 'max_free_online_users') {
      print("PlaceholderConfigDriver: getInt for '$key' -> returning 10");
      return 10;
    }
    return 0;
  }
}

// This is a placeholder implementation for the IPaymentDriver.
// A real implementation would use a service like RevenueCat.
class _PlaceholderPaymentDriver implements IPaymentDriver {
  @override
  Future<void> init() async {
    print("PlaceholderPaymentDriver: init called");
  }

  @override
  Future<bool> get isProUser async {
    // For testing, we can toggle this to simulate a pro user.
    print("PlaceholderPaymentDriver: isProUser -> returning false");
    return false;
  }

  @override
  Future<void> purchasePro() async {
    print("PlaceholderPaymentDriver: purchasePro called");
  }

  @override
  Future<void> restorePurchases() async {
    print("PlaceholderPaymentDriver: restorePurchases called");
  }
}


/// The main entry point for the Bingo SDK.
/// It handles the initialization of all necessary drivers and services.
class BingoSDK {
  /// Initializes the SDK.
  ///
  /// This method should be called once at the start of the application.
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
    // In a real app, you would initialize the actual drivers here.
    getIt.registerSingleton<IConfigDriver>(_PlaceholderConfigDriver());
    getIt.registerSingleton<IPaymentDriver>(_PlaceholderPaymentDriver());

    // Initialize the payment driver
    await getIt<IPaymentDriver>().init();

    // Register the AccessControlService which depends on the drivers
    getIt.registerSingleton<AccessControlService>(
      AccessControlService(
        config: getIt<IConfigDriver>(),
        payment: getIt<IPaymentDriver>(),
      ),
    );

    // TODO: Initialize and register other drivers (Audio, GameConnection) here.
  }
}
