import 'dart:async';
import 'dart:developer'; // Import for log
import 'dart:math' hide log;

import 'package:intl/intl.dart';
import 'package:bingo_app/shared/services/subscription_service.dart';
import 'package:bingo_app/shared/services/ai_service.dart';
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
  List<String> _players = [];
  StreamSubscription? _playersSubscription;

  int? get lastNumber => _lastNumber;
  List<int> get drawnNumbers => _drawnNumbers;
  List<Claim> get bingoClaims => _bingoClaims;
  List<String> get players => _players;
  int get playerCount => _players.length;

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
    _playersSubscription = _gameConnection.connectedPlayersStream.listen((
      players,
    ) {
      _players = players;
      notifyListeners();
    });

    _gameConnection.errorStream.listen((errorMsg) {
       if (errorMsg == 'PAYWALL_TRIGGERED') {
          _actionController.add(ShowPaywall());
       } else {
          _actionController.add(ShowError(errorMsg));
       }
    });
  }

  Future<bool> get canDrawNextNumber async {
    // Check if the "is_globo_paid" feature is paid and if the user is PRO.
    final bool isGloboPaidFeature = _configDriver.getBool('is_globo_paid');
    return !isGloboPaidFeature ||
        await _accessControlService.canAccess('is_globo_paid');
  }

  Timer? _autoPlayTimer;
  bool _isAutoPlaying = false;
  bool get isAutoPlaying => _isAutoPlaying;

  // Manual Mode: Host enters a number
  Future<void> drawManualNumber(int number) async {
    if (_isAutoPlaying) return;

    // Validation
    if (number < 1 || number > 75) {
      _actionController.add(ShowError('Número deve ser entre 1 e 75'));
      return;
    }
    if (_drawnNumbers.contains(number)) {
      _actionController.add(ShowError('Número $number já foi sorteado!'));
      return;
    }

    _processDraw(number);
  }

  // Auto Mode: App draws randomly
  Future<void> toggleAutoPlay() async {
    if (_isAutoPlaying) {
      _stopAutoPlay();
    } else {
      await _startAutoPlay();
    }
  }

  Future<void> _startAutoPlay() async {
    // Check Premium
    final isPremium =
        await SubscriptionService.checkSubscriptionStatus(); // Using new method
    if (!isPremium) {
      _actionController.add(ShowPaywall());
      return;
    }

    _isAutoPlaying = true;
    notifyListeners();

    // Initial draw immediately? Or wait? Let's wait.
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_availableNumbers.isEmpty) {
        _stopAutoPlay();
        return;
      }
      _drawRandomNumber();
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
    _isAutoPlaying = false;
    notifyListeners();
  }

  // Single Random Draw (can be used by AutoPlay or manual click)
  Future<void> drawRandomNumber() async {
    // If used manually, it might be free or paid depending on rules.
    // Assuming 'Globo Virtual' single click is allowed or maybe restricted.
    // user said 'Globo Automatico' is paid. 'Inserir valores' is free.
    // To be safe, let's treat Random Draw as part of 'Globo Virtual' (Premium) or just Auto.
    // Let's allow single random draw for now but prioritize Manual Input for free.
    _drawRandomNumber();
  }

  void _drawRandomNumber() {
    if (_availableNumbers.isEmpty) return;

    final int randomIndex = _random.nextInt(_availableNumbers.length);
    final int drawnNumber = _availableNumbers.elementAt(randomIndex);
    _processDraw(drawnNumber);
  }

  Future<void> _processDraw(int number) async {
    if (_availableNumbers.contains(number)) {
      _availableNumbers.remove(number);
    }

    _lastNumber = number;
    _drawnNumbers = List.from(_drawnNumbers)..add(number);

    // Broadcast the number to all connected players
    await _gameConnection.broadcastEvent(NumberDrawnEvent(number: number));

    // Announce AI Joke (Local or Remote)
    final joke = AiService.getJokeForNumber(number, locale: Intl.defaultLocale);
    // TODO(ux): trocar ShowError por uma acao AnnounceNumber (PR de UX).
    _actionController.add(ShowError(joke));

    notifyListeners();
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
    _playersSubscription?.cancel();
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
