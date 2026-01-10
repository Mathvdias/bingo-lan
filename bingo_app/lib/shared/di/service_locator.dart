import 'package:bingo_app/features/host/host_setup_view_model.dart';
import 'package:bingo_app/features/player/player_game_view_model.dart';
import 'package:bingo_app/features/player/player_scan_view_model.dart';
import 'package:bingo_core/bingo_core.dart'; // Import IGameConnection
import 'package:get_it/get_it.dart';

// Create a global instance of GetIt
final GetIt serviceLocator = GetIt.instance;

/// Sets up the service locator for dependency injection.
///
/// This function should be called once at app startup.
void setupServiceLocator() {
  // -------------------
  // ViewModels
  // -------------------
  // ViewModels are registered as factories, meaning a new instance is created
  // every time they are requested. This is important to prevent state from
  // leaking between different screens.

  serviceLocator.registerFactory(() => HostSetupViewModel(
        gameConnection: serviceLocator<IGameConnection>(),
      ));
  serviceLocator.registerFactory(() => PlayerScanViewModel());
  serviceLocator.registerFactoryParam<PlayerGameViewModel, int, void>(
    (cardId, _) => PlayerGameViewModel(cardId: cardId),
  );

  // -------------------
  // Services & Drivers
  // -------------------
  // Services from the bingo_core package are already registered inside
  // BingoSDK.initialize(). We can access them via `serviceLocator`.
}
