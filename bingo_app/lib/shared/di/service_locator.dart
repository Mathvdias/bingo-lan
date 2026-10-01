import 'dart:developer'; // Import for log
import 'package:bingo_app/features/host/host_invite_view_model.dart';
import 'package:bingo_app/features/host/host_room_view_model.dart';
import 'package:bingo_app/features/host/host_setup_view_model.dart';
import 'package:bingo_app/features/paywall/paywall_analytics.dart';
import 'package:bingo_app/features/paywall/paywall_view_model.dart';
import 'package:bingo_app/features/paywall/purchases_gateway.dart';
import 'package:bingo_app/features/player/player_game_view_model.dart';
import 'package:bingo_app/features/player/player_scan_view_model.dart';
import 'package:bingo_app/features/solo/solo_game_view_model.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:get_it/get_it.dart';

// Create a global instance of GetIt
final GetIt serviceLocator = GetIt.instance;

/// Sets up the service locator for dependency injection.
///
/// This function should be called once at app startup.
void setupServiceLocator() {
  log('Setting up service locator...');

  // ViewModels
  serviceLocator.registerFactory(
    () => HostSetupViewModel(
      gameConnection: serviceLocator<IGameConnection>(),
      networkInfoDriver: serviceLocator<INetworkInfoDriver>(),
    ),
  );

  serviceLocator.registerFactory(
    () =>
        HostInviteViewModel(gameConnection: serviceLocator<IGameConnection>()),
  );

  serviceLocator.registerFactory(
    () =>
        PlayerScanViewModel(gameConnection: serviceLocator<IGameConnection>()),
  );

  serviceLocator.registerFactoryParam<PlayerGameViewModel, int, void>(
    (cardId, _) => PlayerGameViewModel(
      cardId: cardId,
      gameConnection: serviceLocator<IGameConnection>(),
    ),
  );

  serviceLocator.registerFactory(
    () => HostRoomViewModel(
      gameConnection: serviceLocator<IGameConnection>(),
      accessControlService: serviceLocator<AccessControlService>(),
      configDriver: serviceLocator<IConfigDriver>(),
    ),
  );

  // Paywall: gateway sobre o RevenueCat + ViewModel por tela
  serviceLocator.registerLazySingleton<PurchasesGateway>(
    () => const RevenueCatPurchasesGateway(),
  );
  serviceLocator.registerFactory(
    () => PaywallViewModel(
      gateway: serviceLocator<PurchasesGateway>(),
      analytics: const FirebasePaywallAnalytics(),
    ),
  );

  // SoloGame ViewModel
  serviceLocator.registerFactory(() => SoloGameViewModel());
}
