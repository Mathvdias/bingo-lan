// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Bingo Lucca';

  @override
  String get startBingo => 'Organiser un Bingo';

  @override
  String get joinBingo => 'Rejoindre un Bingo';

  @override
  String get upgrade => 'Mettre à niveau';

  @override
  String get premiumBadge => 'PREMIUM';

  @override
  String get manualGlobe => 'Manuel (Physique)';

  @override
  String get virtualGlobe => 'Virtuel';

  @override
  String get autoGlobe => 'Globe Automatique (Premium)';

  @override
  String get drawRandom => 'Tirer au sort';

  @override
  String get confirm => 'Confirmer';

  @override
  String get numberInput => 'Numéro';

  @override
  String get typeNumberHint => 'Entrez le numéro tiré';

  @override
  String get errorInvalidNumber => 'Le numéro doit être compris entre 1 et 75';

  @override
  String get errorNumberDrawn => 'Le numéro a déjà été tiré!';

  @override
  String get paywallTitle => 'Fonctionnalité Payante';

  @override
  String get paywallMessage =>
      'Le Globe Automatique est payant. Mettez à niveau!';

  @override
  String get stopRoomTitle => 'Fermer la Salle';

  @override
  String get stopRoomMessage =>
      'Êtes-vous sûr de vouloir fermer la salle ? Tous les joueurs seront déconnectés.';

  @override
  String get no => 'Non';

  @override
  String get yes => 'Oui';

  @override
  String get hostRoomTitle => 'Salle de Bingo (Host)';

  @override
  String get playersInRoom => 'joueurs dans la salle';

  @override
  String get shoutedBingo => 'a crié BINGO !';

  @override
  String get cardId => 'ID de Carte :';

  @override
  String get manualInputInstruction =>
      'Tapez le numéro tiré sur le globe physique';
}
