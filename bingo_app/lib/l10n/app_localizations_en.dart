// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Bingo Lucca';

  @override
  String get startBingo => 'Organizar um Bingo';

  @override
  String get joinBingo => 'Entrar em um Bingo';

  @override
  String get upgrade => 'Upgrade';

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
  String get stopRoomTitle => 'End Room';

  @override
  String get stopRoomMessage =>
      'Are you sure you want to close the room? All players will be disconnected.';

  @override
  String get no => 'No';

  @override
  String get yes => 'Yes';

  @override
  String get hostRoomTitle => 'Bingo Room (Host)';

  @override
  String get playersInRoom => 'players in room';

  @override
  String get shoutedBingo => 'shouted BINGO!';

  @override
  String get cardId => 'Card ID:';

  @override
  String get manualInputInstruction =>
      'Type the number drawn on the physical globe';
}
