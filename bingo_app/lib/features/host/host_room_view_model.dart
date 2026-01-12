import 'dart:async';
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

  final _actionController = StreamController<HostRoomAction>.broadcast();
  Stream<HostRoomAction> get actionStream => _actionController.stream;

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
      log('Cannot draw next number: Globo is a paid feature!');
      _actionController.add(ShowPaywall());
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
        final shoutBingoEvent = event;
        _bingoClaims = List.from(_bingoClaims)
          ..add(
            Claim(
              cardId: shoutBingoEvent.cardId,
              playerName: shoutBingoEvent.playerName,
            ),
          );
        notifyListeners();
      } else {
        log('Unknown player event received: $event');
      }
    });
  }

  Future<void> validateClaim(Claim claim) async {
    setLoading(true);

    // 1. Re-generate the player's card
    final BingoCard card = BingoCard(id: claim.cardId);

    // 2. Check if it has Bingo against drawn numbers
    final bool hasBingo = card.hasBingo(_drawnNumbers);

    if (hasBingo) {
      log('BINGO CONFIRMED for ${claim.playerName}!');
      await _gameConnection.broadcastEvent(
        GameOverEvent(winnerName: claim.playerName),
      );
    } else {
      log('FALSE BINGO by ${claim.playerName}');
      await _gameConnection.broadcastEvent(
        RejectClaimEvent(playerName: claim.playerName),
      );
    }

    _bingoClaims.remove(claim);
    notifyListeners();
    setLoading(false);
  }

  Future<void> stopGame() async {
    await _gameConnection.disconnect();
  }

  @override
  void dispose() {
    stopGame();
    _actionController.close();
    super.dispose();
  }
}

sealed class HostRoomAction {}

class ShowPaywall extends HostRoomAction {}

class ShowError extends HostRoomAction {
  final String message;
  ShowError(this.message);
}
