import 'dart:developer'; // Import for log
import 'package:bingo_app/features/host/host_invite_view_model.dart';
import 'package:bingo_app/features/host/host_room_view_model.dart'; // Import HostRoomViewModel
import 'package:bingo_app/features/host/host_setup_view_model.dart';
import 'package:bingo_app/features/paywall/paywall_view_model.dart'; // Import PaywallViewModel
import 'package:bingo_app/features/player/player_game_view_model.dart';
import 'package:bingo_app/features/player/player_scan_view_model.dart';
import 'package:bingo_core/bingo_core.dart'; // Import IGameConnection, AccessControlService, IConfigDriver, INetworkInfoDriver, IUUIDDriver
import 'package:get_it/get_it.dart';

// Create a global instance of GetIt
final GetIt serviceLocator = GetIt.instance;

/// Sets up the service locator for dependency injection.
///
/// This function should be called once at app startup.
void setupServiceLocator() {
  log('Setting up service locator...');
  // -------------------
  // ViewModels
  // -------------------
  // ViewModels are registered as factories, meaning a new instance is created
  // every time they are requested. This is important to prevent state from
  // leaking between different screens.

  serviceLocator.registerFactory(
    () => HostSetupViewModel(
      gameConnection: serviceLocator<IGameConnection>(),
      networkInfoDriver: serviceLocator<INetworkInfoDriver>(),
      uuidDriver: serviceLocator<IUUIDDriver>(),
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
  serviceLocator.registerFactory(
    () => PaywallViewModel(paymentDriver: serviceLocator<IPaymentDriver>()),
  );

  // -------------------
  // Services & Drivers
  // -------------------
  // Services from the bingo_core package are already registered inside
  // BingoSDK.initialize(). We can access them via `serviceLocator`.
}
