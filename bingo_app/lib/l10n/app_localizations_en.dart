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
  String get startBingo => 'Host a Bingo';

  @override
  String get joinBingo => 'Join a Bingo';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get premiumBadge => 'PREMIUM';

  @override
  String get manualGlobe => 'Manual (Physical Globe)';

  @override
  String get virtualGlobe => 'Virtual';

  @override
  String get autoGlobe => 'Auto Globe (Premium)';

  @override
  String get drawRandom => 'Draw (Random)';

  @override
  String get confirm => 'Confirm';

  @override
  String get numberInput => 'Number';

  @override
  String get typeNumberHint => 'Type the drawn number';

  @override
  String get errorInvalidNumber => 'Number must be between 1 and 75';

  @override
  String get errorNumberDrawn => 'Number already drawn!';

  @override
  String get paywallTitle => 'Premium Feature';

  @override
  String get paywallMessage => 'Auto Globe is a premium feature. Upgrade now!';

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
