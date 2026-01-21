// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Bingo Lucca';

  @override
  String get startBingo => 'Organizar um Bingo';

  @override
  String get joinBingo => 'Entrar em um Bingo';

  @override
  String get upgrade => 'Melhorar Conta';

  @override
  String get premiumBadge => 'PREMIUM';

  @override
  String get manualGlobe => 'Manual (Físico)';

  @override
  String get virtualGlobe => 'Virtual';

  @override
  String get autoGlobe => 'Globo Automático (Premium)';

  @override
  String get drawRandom => 'Sortear (Aleatório)';

  @override
  String get confirm => 'Confirmar';

  @override
  String get numberInput => 'Número';

  @override
  String get typeNumberHint => 'Digite o número sorteado';

  @override
  String get errorInvalidNumber => 'Número deve ser entre 1 e 75';

  @override
  String get errorNumberDrawn => 'Número já foi sorteado!';

  @override
  String get paywallTitle => 'Recurso Pago';

  @override
  String get paywallMessage =>
      'O Globo Automático é um recurso pago. Faça upgrade!';

  @override
  String get stopRoomTitle => 'Encerrar Sala';

  @override
  String get stopRoomMessage =>
      'Você tem certeza que deseja encerrar a sala? Todos os jogadores serão desconectados.';

  @override
  String get no => 'Não';

  @override
  String get yes => 'Sim';

  @override
  String get hostRoomTitle => 'Sala do Bingo (Host)';

  @override
  String get playersInRoom => 'jogadores na sala';

  @override
  String get shoutedBingo => 'gritou BINGO!';

  @override
  String get cardId => 'Cartela ID:';

  @override
  String get manualInputInstruction =>
      'Digite o número sorteado no globo físico';
}
