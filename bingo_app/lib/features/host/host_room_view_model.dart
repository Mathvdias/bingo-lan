import 'dart:developer'; // Import for log
import 'dart:math' hide log;

import 'package:bingo_app/shared/view_models/base_view_model.dart';
import 'package:bingo_core/bingo_core.dart'; // Import core types including events

// Placeholder for Claim model
class Claim {
  final int cardId;
  final String playerName;
  Claim({required this.cardId, required this.playerName});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Claim &&
        other.cardId == cardId &&
        other.playerName == playerName;
  }

  @override
  int get hashCode => cardId.hashCode ^ playerName.hashCode;
}

class HostRoomViewModel extends BaseViewModel {
  final IGameConnection _gameConnection;
  final AccessControlService _accessControlService;
  final IConfigDriver _configDriver;

  int? _lastNumber;
  List<int> _drawnNumbers = [];
  List<Claim> _bingoClaims = [];

  int? get lastNumber => _lastNumber;
  List<int> get drawnNumbers => _drawnNumbers;
  List<Claim> get bingoClaims => _bingoClaims;

  // Bingo numbers state
  final Set<int> _availableNumbers = Set<int>.from(
    List<int>.generate(75, (index) => index + 1),
  );
  final Random _random = Random();

  HostRoomViewModel({
    required IGameConnection gameConnection,
    required AccessControlService accessControlService,
    required IConfigDriver configDriver,
  }) : _gameConnection = gameConnection,
       _accessControlService = accessControlService,
       _configDriver = configDriver {
    _listenToPlayerEvents();
  }

  Future<bool> get canDrawNextNumber async {
    // Check if the "is_globo_paid" feature is paid and if the user is PRO.
    final bool isGloboPaidFeature = _configDriver.getBool('is_globo_paid');
    return !isGloboPaidFeature ||
        await _accessControlService.canAccess('is_globo_paid');
  }

  Future<void> drawNextNumber() async {
    if (!await canDrawNextNumber) {
      // TODO: Show paywall or error message
      log('Cannot draw next number: Globo is a paid feature!');
      return;
    }

    if (_availableNumbers.isEmpty) {
      log('All numbers have been drawn!');
      return;
    }

    setLoading(true);

    // Draw a random number
    final int randomIndex = _random.nextInt(_availableNumbers.length);
    final int drawnNumber = _availableNumbers.elementAt(randomIndex);
    _availableNumbers.remove(drawnNumber);

    _lastNumber = drawnNumber;
    _drawnNumbers = List.from(_drawnNumbers)
      ..add(drawnNumber); // Add to history

    // Broadcast the number to all connected players
    await _gameConnection.broadcastEvent(NumberDrawnEvent(number: drawnNumber));

    notifyListeners();
    setLoading(false);
  }

  void _listenToPlayerEvents() {
    _gameConnection.eventStream.listen((event) {
      if (event is ShoutBingoEvent) {
        final shoutBingoEvent = event as ShoutBingoEvent; // Explicit cast
        _bingoClaims = List.from(_bingoClaims)
          ..add(
            Claim(
              cardId: shoutBingoEvent.cardId,
              playerName: shoutBingoEvent.playerName,
            ),
          );
        notifyListeners();
      }
      // TODO: Handle other player events
    });
  }

  void validateClaim(Claim claim) {
    setLoading(true);
    // TODO: Implement logic to validate the claim based on the bingo card and drawn numbers.
    // This will involve:
    // 1. Re-generating the player's card using BingoCard.matrix(_cardId).n    // 2. Comparing the card against _drawnNumbers.
    log('Validating claim for card ID: ${claim.cardId} by ${claim.playerName}');
    _bingoClaims.remove(
      claim,
    ); // Remove from pending claims after validation attempt
    notifyListeners();
    setLoading(false);
  }
}
