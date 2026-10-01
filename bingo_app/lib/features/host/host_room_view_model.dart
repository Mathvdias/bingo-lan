import 'dart:async';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:bingo_app/shared/services/analytics_service.dart';
import 'package:bingo_app/shared/services/caller_phrases.dart';
import 'package:bingo_app/shared/services/subscription_service.dart';
import 'package:bingo_app/shared/view_models/base_view_model.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:intl/intl.dart';

/// Fase da rodada no host.
enum GamePhase {
  /// Sala aberta, nenhum número sorteado ainda.
  waiting,

  /// Sorteio em andamento.
  playing,

  /// Houve um bingo validado. Sortear fica bloqueado até "nova rodada".
  over,
}

/// Erros exibidos na tela do host (a tela traduz).
enum HostRoomError { invalidNumber, alreadyDrawn, connection }

/// Reivindicação de bingo, chaveada pelo id que o host atribuiu ao jogador.
class Claim {
  final String playerId;
  final int cardId;
  final String playerName;

  const Claim({
    required this.playerId,
    required this.cardId,
    required this.playerName,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Claim &&
        other.playerId == playerId &&
        other.cardId == cardId &&
        other.playerName == playerName;
  }

  @override
  int get hashCode => Object.hash(playerId, cardId, playerName);
}

class HostRoomViewModel extends BaseViewModel {
  static const Duration autoPlayInterval = Duration(seconds: 4);

  final IGameConnection _gameConnection;
  final AccessControlService _accessControlService;
  final IConfigDriver _configDriver;
  final Random _random;

  final _actionController = StreamController<HostRoomAction>.broadcast();
  Stream<HostRoomAction> get actionStream => _actionController.stream;

  int? _lastNumber;
  List<int> _drawnNumbers = const [];
  List<Claim> _bingoClaims = const [];
  List<String> _players = const [];
  GamePhase _phase = GamePhase.waiting;
  String? _winnerName;
  String? _winnerId;

  StreamSubscription<List<String>>? _playersSub;
  StreamSubscription<GameEvent>? _eventsSub;
  StreamSubscription<String>? _errorsSub;

  int? get lastNumber => _lastNumber;
  List<int> get drawnNumbers => _drawnNumbers;

  /// Histórico do mais recente para o mais antigo (faixa da tela).
  List<int> get drawnNumbersNewestFirst => _drawnNumbers.reversed.toList();
  List<Claim> get bingoClaims => _bingoClaims;
  List<String> get players => _players;
  int get playerCount => _players.length;
  GamePhase get phase => _phase;
  bool get isGameOver => _phase == GamePhase.over;
  String? get winnerName => _winnerName;
  String? get winnerId => _winnerId;

  /// Sortear só é permitido fora de [GamePhase.over] e com números restantes.
  bool get canDraw => !isGameOver && _availableNumbers.isNotEmpty;

  /// Desfazer: há bola para tirar, a rodada não acabou e o globo automático
  /// não está rodando (pausado pode).
  bool get canUndo => _drawnNumbers.isNotEmpty && !isGameOver && !isAutoRunning;

  // Bingo numbers state
  final Set<int> _availableNumbers = _allNumbers();

  static Set<int> _allNumbers() =>
      Set<int>.from(List<int>.generate(75, (index) => index + 1));

  HostRoomViewModel({
    required IGameConnection gameConnection,
    required AccessControlService accessControlService,
    required IConfigDriver configDriver,
    Random? random,
  }) : _gameConnection = gameConnection,
       _accessControlService = accessControlService,
       _configDriver = configDriver,
       _random = random ?? Random() {
    _eventsSub = _gameConnection.eventStream.listen(_onPlayerEvent);
    // Quem entrou pela tela de convite já está na conexão; o stream só emite
    // mudanças, então a lista começa do valor atual.
    _players = _gameConnection.connectedPlayers;
    _playersSub = _gameConnection.connectedPlayersStream.listen((players) {
      _players = players;
      notifyListeners();
    });
    _errorsSub = _gameConnection.errorStream.listen((errorMsg) {
      if (errorMsg == 'PAYWALL_TRIGGERED') {
        _actionController.add(ShowPaywall(source: 'room_capacity'));
      } else {
        _actionController.add(ShowError(HostRoomError.connection));
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
  bool _autoPaused = false;

  /// Globo automático ligado (rodando ou pausado).
  bool get isAutoPlaying => _isAutoPlaying;

  /// Globo automático ligado e em pausa: o host pode sortear ou desfazer.
  bool get isAutoPaused => _isAutoPlaying && _autoPaused;

  /// Globo automático sorteando sozinho neste momento.
  bool get isAutoRunning => _isAutoPlaying && !_autoPaused;

  // Manual Mode: Host enters a number
  Future<void> drawManualNumber(int number) async {
    if (isAutoRunning || isGameOver) return;

    if (number < 1 || number > 75) {
      _actionController.add(ShowError(HostRoomError.invalidNumber));
      return;
    }
    if (_drawnNumbers.contains(number)) {
      _actionController.add(ShowError(HostRoomError.alreadyDrawn));
      return;
    }

    await _processDraw(number);
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
    if (isGameOver) return;
    // Gate lê o cache do status premium (atualizado pelo listener do RevenueCat).
    if (!SubscriptionService.isPremium.value) {
      _actionController.add(ShowPaywall(source: 'auto_globe'));
      return;
    }

    _isAutoPlaying = true;
    _autoPaused = false;
    notifyListeners();
    unawaited(AnalyticsService.trackFeatureUsed('auto_globe'));
    _scheduleAutoPlay();
  }

  void _scheduleAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(autoPlayInterval, (_) {
      if (!canDraw) {
        _stopAutoPlay();
        return;
      }
      _drawRandomNumber();
    });
  }

  /// Pausa o globo automático sem desligá-lo: o timer para, o switch continua
  /// ligado e o host pode desfazer ou sortear na mão até [resumeAutoPlay].
  void pauseAutoPlay() {
    if (!isAutoRunning) return;
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
    _autoPaused = true;
    notifyListeners();
  }

  void resumeAutoPlay() {
    if (!isAutoPaused || isGameOver) return;
    _autoPaused = false;
    notifyListeners();
    _scheduleAutoPlay();
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
    _autoPaused = false;
    if (_isAutoPlaying) {
      _isAutoPlaying = false;
      notifyListeners();
    }
  }

  /// Sorteio aleatório único (globo virtual).
  Future<void> drawRandomNumber() async {
    if (isAutoRunning) return;
    await _drawRandomNumber();
  }

  /// Desfaz a última bola: sai do histórico, volta ao globo e os jogadores
  /// recebem um STATE_SYNC com a lista corrigida.
  Future<void> undoLastDraw() async {
    if (!canUndo) return;
    final removed = _drawnNumbers.last;
    _drawnNumbers = List<int>.unmodifiable(
      _drawnNumbers.sublist(0, _drawnNumbers.length - 1),
    );
    _availableNumbers.add(removed);
    _lastNumber = _drawnNumbers.isEmpty ? null : _drawnNumbers.last;
    if (_drawnNumbers.isEmpty) _phase = GamePhase.waiting;
    notifyListeners();
    _actionController.add(AnnounceUndo(number: removed));

    await _gameConnection.broadcastEvent(
      StateSyncEvent(drawnNumbers: _drawnNumbers),
    );
  }

  Future<void> _drawRandomNumber() async {
    if (!canDraw) return;
    final int randomIndex = _random.nextInt(_availableNumbers.length);
    final int drawnNumber = _availableNumbers.elementAt(randomIndex);
    await _processDraw(drawnNumber);
  }

  Future<void> _processDraw(int number) async {
    if (isGameOver) return;
    _availableNumbers.remove(number);

    _lastNumber = number;
    _drawnNumbers = List<int>.unmodifiable([..._drawnNumbers, number]);
    _phase = GamePhase.playing;

    // A tela mostra o número antes de qualquer ida à rede.
    notifyListeners();
    final phrase = CallerPhrases.getJokeForNumber(
      number,
      locale: Intl.defaultLocale,
    );
    _actionController.add(AnnounceNumber(number: number, phrase: phrase));

    await _gameConnection.broadcastEvent(NumberDrawnEvent(number: number));
  }

  void _onPlayerEvent(GameEvent event) {
    if (event is ShoutBingoEvent) {
      final playerId = event.playerId;
      final cardId = event.cardId;
      if (playerId == null || cardId == null) {
        log('Ignoring SHOUT_BINGO without server identity.');
        return;
      }
      if (isGameOver) {
        log('Ignoring SHOUT_BINGO after game over.');
        return;
      }
      final claim = Claim(
        playerId: playerId,
        cardId: cardId,
        playerName: event.playerName ?? '',
      );
      if (_bingoClaims.any((c) => c.playerId == playerId)) return;
      _bingoClaims = List<Claim>.unmodifiable([..._bingoClaims, claim]);
      notifyListeners();
    } else {
      log('Ignoring event on host: ${event.runtimeType}');
    }
  }

  /// Valida a cartela que o host atribuiu ao jogador contra os sorteados.
  Future<void> validateClaim(Claim claim) async {
    if (isGameOver) return;
    setLoading(true);

    final BingoCard card = BingoCard(id: claim.cardId);
    final bool hasBingo = card.hasBingo(_drawnNumbers);

    _bingoClaims = List<Claim>.unmodifiable(
      _bingoClaims.where((c) => c != claim),
    );

    if (hasBingo) {
      _phase = GamePhase.over;
      _winnerName = claim.playerName;
      _winnerId = claim.playerId;
      _stopAutoPlay();
      notifyListeners();
      await _gameConnection.broadcastEvent(
        GameOverEvent(winnerName: claim.playerName, winnerId: claim.playerId),
      );
      unawaited(
        AnalyticsService.trackBingoWin('host_room', cardId: claim.cardId),
      );
    } else {
      notifyListeners();
      await _gameConnection.broadcastEvent(
        RejectClaimEvent(
          playerName: claim.playerName,
          playerId: claim.playerId,
        ),
      );
    }

    setLoading(false);
  }

  /// Nova rodada na mesma sala: zera o sorteio e avisa os jogadores.
  Future<void> newRound() async {
    _stopAutoPlay();
    _availableNumbers
      ..clear()
      ..addAll(_allNumbers());
    _drawnNumbers = const [];
    _lastNumber = null;
    _bingoClaims = const [];
    _winnerName = null;
    _winnerId = null;
    _phase = GamePhase.waiting;
    notifyListeners();
    await _gameConnection.broadcastEvent(
      StateSyncEvent(drawnNumbers: const []),
    );
  }

  /// Encerra a sala: ROOM_CLOSED para todos e servidor derrubado.
  Future<void> stopGame() async {
    _stopAutoPlay();
    await _gameConnection.disconnect();
  }

  @override
  void dispose() {
    _playersSub?.cancel();
    _eventsSub?.cancel();
    _errorsSub?.cancel();
    _autoPlayTimer?.cancel();
    unawaited(_gameConnection.disconnect());
    _actionController.close();
    super.dispose();
  }
}

sealed class HostRoomAction {}

/// Pede para abrir o paywall. [source] alimenta o funil de analytics.
class ShowPaywall extends HostRoomAction {
  final String source;
  ShowPaywall({required this.source});
}

class ShowError extends HostRoomAction {
  final HostRoomError error;
  ShowError(this.error);
}

/// Número sorteado + frase do cantador. Não é erro: vira um toast neutro.
class AnnounceNumber extends HostRoomAction {
  final int number;
  final String phrase;
  AnnounceNumber({required this.number, required this.phrase});
}

/// Bola desfeita pelo host (toast neutro).
class AnnounceUndo extends HostRoomAction {
  final int number;
  AnnounceUndo({required this.number});
}
