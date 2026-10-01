import 'dart:async';
import 'dart:developer';

import 'package:bingo_app/features/player/player_game_args.dart';
import 'package:bingo_app/shared/view_models/base_view_model.dart';
import 'package:bingo_core/bingo_core.dart';

enum PlayerGamePhase { playing, over }

/// Eventos de uma vez só (snackbar); estado persistente fica nos getters.
sealed class PlayerGameAction {}

class ClaimRejected extends PlayerGameAction {}

class PlayerGameViewModel extends BaseViewModel {
  static const Duration shoutCooldown = Duration(seconds: 5);

  final PlayerGameArgs args;
  final IGameConnection _gameConnection;
  final DateTime Function() _now;

  late final BingoCard bingoCard;
  final Set<int> _markedNumbers = {};
  List<int> _drawnNumbers = const [];
  Set<int> _calledSet = const {};

  PlayerGamePhase _phase = PlayerGamePhase.playing;
  String? _winnerName;
  bool _isWinner = false;
  bool _roomClosed = false;
  GameConnectionState _connectionState;

  DateTime? _lastShoutAt;
  Timer? _cooldownTimer;

  StreamSubscription<GameEvent>? _eventsSub;
  StreamSubscription<GameConnectionState>? _stateSub;
  final _actions = StreamController<PlayerGameAction>.broadcast();

  PlayerGameViewModel({
    required this.args,
    required IGameConnection gameConnection,
    DateTime Function()? clock,
  }) : _gameConnection = gameConnection,
       _now = clock ?? DateTime.now,
       _connectionState = gameConnection.connectionState {
    bingoCard = BingoCard(id: args.cardId);
    _setDrawn(args.initialDrawnNumbers);
    _eventsSub = _gameConnection.eventStream.listen(_onEvent);
    _stateSub = _gameConnection.connectionStateStream.listen((state) {
      _connectionState = state;
      if (state == GameConnectionState.roomClosed) _roomClosed = true;
      notifyListeners();
    });
  }

  // ------------------------------------------------------------------ getters
  int get cardId => args.cardId;
  String get playerId => args.playerId;
  String get playerName => args.playerName;
  Stream<PlayerGameAction> get actionStream => _actions.stream;

  Set<int> get markedNumbers => _markedNumbers;
  List<int> get drawnNumbers => _drawnNumbers;
  Set<int> get calledNumbers => _calledSet;
  int? get lastNumber => _drawnNumbers.isEmpty ? null : _drawnNumbers.last;

  PlayerGamePhase get phase => _phase;
  bool get isGameOver => _phase == PlayerGamePhase.over;
  String? get winnerName => _winnerName;
  bool get isWinner => _isWinner;
  bool get roomClosed => _roomClosed;
  GameConnectionState get connectionState => _connectionState;
  bool get isConnected => _connectionState == GameConnectionState.connected;

  bool get isShoutOnCooldown => shoutCooldownRemaining > Duration.zero;

  Duration get shoutCooldownRemaining {
    final last = _lastShoutAt;
    if (last == null) return Duration.zero;
    final remaining = shoutCooldown - _now().difference(last);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get canShout =>
      _phase == PlayerGamePhase.playing &&
      !_roomClosed &&
      isConnected &&
      !isShoutOnCooldown;

  // ------------------------------------------------------------------ actions

  /// Informa o nome ao host (ele limita a 24 caracteres e desduplica).
  Future<void> announceName() {
    return _gameConnection.sendPlayerEvent(PlayerNameEvent(name: playerName));
  }

  void markNumber(int number) {
    if (_phase == PlayerGamePhase.over || _roomClosed) return;
    if (!bingoCard.matrix.contains(number) || number == 0) return;
    if (!_markedNumbers.remove(number)) _markedNumbers.add(number);
    notifyListeners();
  }

  /// Envia a reivindicação. Retorna `false` se bloqueado (cooldown, fim de
  /// jogo, sem conexão) ou se o envio falhar.
  Future<bool> shoutBingo() async {
    if (!canShout) return false;
    _lastShoutAt = _now();
    _startCooldownTicker();
    notifyListeners();
    try {
      await _gameConnection.sendPlayerEvent(ShoutBingoEvent());
      return true;
    } catch (e) {
      log('Error shouting Bingo: $e');
      return false;
    }
  }

  Future<void> retryConnection() => _gameConnection.reconnect();

  Future<void> leaveRoom() => _gameConnection.disconnect();

  // ------------------------------------------------------------------- events
  void _onEvent(GameEvent event) {
    if (event is NumberDrawnEvent) {
      if (!_calledSet.contains(event.number)) {
        _setDrawn([..._drawnNumbers, event.number]);
      }
    } else if (event is StateSyncEvent) {
      final newRound = event.drawnNumbers.isEmpty && _drawnNumbers.isNotEmpty;
      _setDrawn(event.drawnNumbers);
      if (newRound || (event.drawnNumbers.isEmpty && isGameOver)) {
        _resetRound();
      }
    } else if (event is GameOverEvent) {
      _phase = PlayerGamePhase.over;
      _winnerName = event.winnerName;
      _isWinner = event.winnerId != null
          ? event.winnerId == playerId
          : event.winnerName == playerName;
    } else if (event is RejectClaimEvent) {
      if (event.playerId == null || event.playerId == playerId) {
        _actions.add(ClaimRejected());
      }
    } else if (event is RoomClosedEvent) {
      _roomClosed = true;
    } else {
      return;
    }
    notifyListeners();
  }

  void _setDrawn(List<int> numbers) {
    _drawnNumbers = List<int>.unmodifiable(numbers);
    _calledSet = Set<int>.unmodifiable(numbers.toSet());
  }

  void _resetRound() {
    _phase = PlayerGamePhase.playing;
    _winnerName = null;
    _isWinner = false;
    _markedNumbers.clear();
  }

  void _startCooldownTicker() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isShoutOnCooldown) {
        timer.cancel();
        _cooldownTimer = null;
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _eventsSub?.cancel();
    _stateSub?.cancel();
    _cooldownTimer?.cancel();
    _actions.close();
    if (_connectionState == GameConnectionState.connected ||
        _connectionState == GameConnectionState.reconnecting ||
        _connectionState == GameConnectionState.connecting) {
      unawaited(_gameConnection.disconnect());
    }
    super.dispose();
  }
}
