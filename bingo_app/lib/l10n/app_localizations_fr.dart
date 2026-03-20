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

  @override
  String get lobbySubtitle => 'Votre fête, vos règles';

  @override
  String get lobbyWifiShowcase =>
      'Le Bingo fonctionne uniquement localement ! Assurez-vous d\'être sur le même réseau Wi-Fi que vos invités.';

  @override
  String get lobbyWifiBannerDefault => 'Jouez sur le réseau Wi-Fi de l\'hôte !';

  @override
  String lobbyWifiBannerConnected(String wifiName) {
    return 'Réseau actuel: $wifiName\nJouez sur le réseau de l\'hôte !';
  }

  @override
  String get buttonWifi => 'WIFI';

  @override
  String get lobbyHostShowcase =>
      'Cliquez ici si VOUS êtes l\'hôte et que vous voulez tirer les boules de bingo.';

  @override
  String get lobbyJoinShowcase =>
      'Cliquez ici pour scanner le code QR et jouer avec une carte sur votre téléphone.';

  @override
  String get lobbySoloShowcase =>
      'Vous voulez tester le jeu en solo hors ligne ? Utilisez ce mode !';

  @override
  String get soloButton => 'Bingo Solo';

  @override
  String get buttonConfig => 'CONFIG';

  @override
  String get scanWifiBannerDefault =>
      'Connectez-vous au réseau Wi-Fi de l\'hôte.';

  @override
  String scanWifiBannerConnected(String wifiName) {
    return 'Réseau: $wifiName\nConnectez-vous au réseau de l\'hôte.';
  }

  @override
  String get scanManualButton => 'Entrer le code manuellement';

  @override
  String get revealNetwork => 'Révéler le réseau';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get termsOfUse => 'Conditions d\'utilisation';

  @override
  String get aboutDeveloper => 'Développeur (GitHub)';

  @override
  String get aboutTitle => 'À propos du Bingo';

  @override
  String get aboutImportantTitle => '⚠️ Important : Même réseau Wi-Fi';

  @override
  String get aboutImportantBody =>
      'Le Bingo fonctionne via une connexion locale sécurisée. Pour que les joueurs trouvent votre salle, TOUT LE MONDE (y compris l\'hôte) doit être connecté au même réseau Wi-Fi.';

  @override
  String get aboutHowToPlayTitle => '📖 Comment jouer (Étape par étape)';

  @override
  String get aboutStep1Title => 'Choisissez l\'Hôte';

  @override
  String get aboutStep1Desc =>
      'Une personne démarre la partie en cliquant sur \'Organiser un Bingo\' et partage le Code de la Salle.';

  @override
  String get aboutStep2Title => 'Joueurs dans la Salle';

  @override
  String get aboutStep2Desc =>
      'Les autres participants cliquent sur \'Rejoindre\' et tapent le code (ou pointent leur caméra sur le Code QR).';

  @override
  String get aboutStep3Title => 'Marquer la Carte';

  @override
  String get aboutStep3Desc =>
      'L\'hôte tire les boules. Touchez le numéro sur la carte de votre téléphone pour le marquer.';

  @override
  String get aboutStep4Title => 'BINGO !';

  @override
  String get aboutStep4Desc =>
      'Carte complétée ? Appuyez sur le bouton \'CRIER BINGO\' avant tout le monde pour gagner !';

  @override
  String get aboutLanguage => '🌐 Langue';

  @override
  String get scanEnterName => 'Entrez votre nom';

  @override
  String get scanJoin => 'Rejoindre';

  @override
  String get scanManualTitle => 'Entrer manuellement';

  @override
  String get scanManualHint =>
      'Collez le code ou le lien de la salle ci-dessous :';

  @override
  String get scanCancel => 'Annuler';

  @override
  String get scanShowcaseScanner =>
      'Pointez votre caméra vers le Code QR de l\'hôte pour rejoindre rapidement la salle.';

  @override
  String get inviteRoomCode => 'Code de la Salle';

  @override
  String get inviteShareLink => 'Partager le lien d\'invitation';

  @override
  String get inviteTitle => 'Inviter des joueurs';

  @override
  String get inviteScanDesc => 'Scannez pour rejoindre la salle !';

  @override
  String inviteShareCodeMessage(String qrData) {
    return 'Jouons au Bingo ! Notre code de salle est : $qrData';
  }

  @override
  String get inviteShareCodeTooltip => 'Partager le code';

  @override
  String inviteShareLinkMessage(String qrData) {
    return 'Viens jouer au Bingo ! Clique simplement depuis ton téléphone : bingo://room/$qrData';
  }

  @override
  String inviteConnectedPlayers(int count) {
    return 'Joueurs Connectés : $count';
  }

  @override
  String get inviteWaitingPlayers => 'En attente de joueurs...';

  @override
  String get inviteStartBingo => 'Démarrer le Bingo !';

  @override
  String get lobbyPremiumTag => 'PREMIUM';

  @override
  String get lobbyUpgradeButton => 'Améliorer';

  @override
  String get playerGameTitle => 'Votre Carte';

  @override
  String get playerGameShout => 'Crier BINGO!';

  @override
  String get playerScanNameHint => 'Ex: Mathieu';

  @override
  String get playerScanTitle => 'Rejoindre un Bingo';

  @override
  String get soloGameTitle => 'Bingo Solo';

  @override
  String get soloGameDraw => 'Tirer un Numéro';

  @override
  String get hostSetupTitle => 'Héberger un Bingo';

  @override
  String get hostSetupRoomHint => 'Ex: Bingo de l\'Oncle Joe';

  @override
  String get hostSetupCreate => 'Créer une Salle';

  @override
  String get hostSetupNameLabel => 'Nommez votre salle';

  @override
  String get hostSetupWifiWarning =>
      'Avertissement: Tous les joueurs DOIVENT être connectés au MÊME RÉSEAU WI-FI pour rejoindre la salle.';

  @override
  String get hostSetupWifiDesc =>
      'Jouez avec des personnes sur le même réseau Wi-Fi. Idéal pour les fêtes et les rassemblements.';

  @override
  String get playerScanCameraHint =>
      'Pointez votre appareil photo sur le code QR de l\'hôte';
}
