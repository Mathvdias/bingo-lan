import 'dart:async';
import 'dart:developer';

import 'package:bingo_app/shared/services/analytics_service.dart';
import 'package:bingo_app/shared/view_models/base_view_model.dart';
import 'package:bingo_core/bingo_core.dart';

/// Por que a entrada na sala falhou. A tela traduz para o idioma do usuário.
enum PlayerScanError {
  /// O QR/código não é um convite válido (ou é de uma versão antiga).
  invalidCode,

  /// O host recusou (token, sala cheia, limite por IP) ou não está acessível.
  rejected,

  /// Conectou mas o host não enviou `JOINED` a tempo.
  timeout,

  unexpected,
}

class PlayerScanViewModel extends BaseViewModel {
  final IGameConnection _gameConnection;
  final Duration joinTimeout;

  PlayerScanError? _error;
  PlayerScanError? get error => _error;

  BingoInvite? _invite;
  BingoInvite? get invite => _invite;

  PlayerScanViewModel({
    required IGameConnection gameConnection,
    this.joinTimeout = const Duration(seconds: 10),
  }) : _gameConnection = gameConnection;

  /// Interpreta o convite, conecta ao host e espera o `JOINED` com a
  /// identidade atribuída pelo servidor. Retorna `null` em caso de erro
  /// (ver [error]).
  Future<JoinedEvent?> onQrCodeScanned(String rawData) async {
    if (isLoading) return null;
    setLoading(true, notify: false);
    _error = null;
    notifyListeners();

    try {
      final invite = BingoInvite.parse(rawData);
      if (invite == null) {
        return _fail(PlayerScanError.invalidCode);
      }
      _invite = invite;

      // Assina antes de conectar para não perder o JOINED; nunca rejeita.
      final joined = _gameConnection.eventStream
          .firstWhere((e) => e is JoinedEvent)
          .timeout(joinTimeout)
          .then<JoinedEvent?>((e) => e as JoinedEvent, onError: (_) => null);

      try {
        await _gameConnection.joinRoom(invite.webSocketUri);
      } catch (e) {
        // Não loga a URI: contém o JWT.
        log('Join refused or host unreachable: ${e.runtimeType}');
        return _fail(PlayerScanError.rejected);
      }

      final event = await joined;
      if (event == null) {
        await _gameConnection.disconnect();
        return _fail(PlayerScanError.timeout);
      }

      unawaited(
        AnalyticsService.trackJoinRoom(
          invite.roomName.isNotEmpty ? invite.roomName : invite.ip,
        ),
      );
      return event;
    } catch (e) {
      log('Unexpected error while joining: $e');
      return _fail(PlayerScanError.unexpected);
    } finally {
      setLoading(false);
    }
  }

  /// O usuário desistiu depois de conectar (ex.: cancelou o nome).
  Future<void> cancelJoin() => _gameConnection.disconnect();

  JoinedEvent? _fail(PlayerScanError error) {
    _error = error;
    notifyListeners();
    return null;
  }
}
