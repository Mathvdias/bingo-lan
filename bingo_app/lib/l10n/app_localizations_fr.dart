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
  String get manualGlobe => 'Manuel';

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
  String playersInRoom(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count joueurs dans la salle',
      one: '1 joueur dans la salle',
      zero: 'Aucun joueur dans la salle',
    );
    return '$_temp0';
  }

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
  String get scanWifiBannerNoWifi =>
      'Vous n\'êtes pas en Wi-Fi. Connectez-vous au réseau de l\'hôte.';

  @override
  String scanWifiBannerOnWifi(String ip) {
    return 'Wi-Fi connecté ($ip). Utilisez le même réseau que l\'hôte.';
  }

  @override
  String get scanManualButton => 'Saisir le code';

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
  String get aboutImportantTitle => 'Important : Même réseau Wi-Fi';

  @override
  String get aboutImportantBody =>
      'Le Bingo fonctionne via une connexion locale sécurisée. Pour que les joueurs trouvent votre salle, TOUT LE MONDE (y compris l\'hôte) doit être connecté au même réseau Wi-Fi.';

  @override
  String get aboutHowToPlayTitle => 'Comment jouer (Étape par étape)';

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
  String get aboutLanguage => 'Langue';

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
  String get inviteTitle => 'Inviter des joueurs';

  @override
  String get inviteScanDesc => 'Scannez pour rejoindre la salle !';

  @override
  String inviteShareLinkMessage(String qrData) {
    return 'Viens jouer au Bingo ! Appuie simplement sur le lien depuis ton téléphone :\n$qrData';
  }

  @override
  String inviteConnectedPlayers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count joueurs connectés',
      one: '1 joueur connecté',
      zero: 'Aucun joueur connecté pour l\'instant',
    );
    return '$_temp0';
  }

  @override
  String get inviteWaitingPlayers => 'En attente de joueurs...';

  @override
  String get inviteStartBingo => 'Démarrer le Bingo !';

  @override
  String get lobbyPremiumTag => 'PREMIUM';

  @override
  String get lobbyUpgradeButton => 'Premium';

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

  @override
  String get paywallHeroTitle => 'Passez Premium';

  @override
  String get paywallHeroSubtitle =>
      'Des fêtes plus grandes, sans limites ni interruptions.';

  @override
  String get paywallBenefitUnlimitedPlayers => 'Joueurs illimités par salle';

  @override
  String get paywallBenefitAutoGlobe =>
      'Globe automatique : l\'app tire les boules pour vous';

  @override
  String get paywallBenefitNoAds => 'Sans publicité';

  @override
  String get paywallPeriodWeekly => 'Hebdomadaire';

  @override
  String get paywallPeriodMonthly => 'Mensuel';

  @override
  String get paywallPeriodTwoMonth => 'Tous les 2 mois';

  @override
  String get paywallPeriodThreeMonth => 'Trimestriel';

  @override
  String get paywallPeriodSixMonth => 'Semestriel';

  @override
  String get paywallPeriodAnnual => 'Annuel';

  @override
  String get paywallPeriodLifetime => 'À vie';

  @override
  String get paywallPeriodCustom => 'Forfait';

  @override
  String get paywallBilledWeekly => 'Facturé chaque semaine';

  @override
  String get paywallBilledMonthly => 'Facturé chaque mois';

  @override
  String get paywallBilledTwoMonth => 'Facturé tous les 2 mois';

  @override
  String get paywallBilledThreeMonth => 'Facturé tous les 3 mois';

  @override
  String get paywallBilledSixMonth => 'Facturé tous les 6 mois';

  @override
  String get paywallBilledAnnual => 'Facturé une fois par an';

  @override
  String get paywallBilledCustom => 'Abonnement';

  @override
  String get paywallOneTimePayment => 'Paiement unique';

  @override
  String paywallSavings(int percent) {
    return 'Économisez $percent%';
  }

  @override
  String paywallCta(String price) {
    return 'Continuer pour $price';
  }

  @override
  String get paywallRestore => 'Restaurer les achats';

  @override
  String get paywallLegal =>
      'Les abonnements se renouvellent automatiquement sauf annulation au moins 24 heures avant la fin de la période en cours. Annulez à tout moment dans les réglages de votre compte de la boutique.';

  @override
  String get paywallEmpty => 'Aucun forfait disponible pour le moment.';

  @override
  String get paywallRetry => 'Réessayer';

  @override
  String get paywallErrorLoad =>
      'Impossible de charger les forfaits. Vérifiez votre connexion et réessayez.';

  @override
  String get paywallErrorPurchase =>
      'L\'achat n\'a pas pu être finalisé. Veuillez réessayer.';

  @override
  String get paywallErrorRestore =>
      'Impossible de restaurer vos achats. Veuillez réessayer.';

  @override
  String get paywallRestoreNothing =>
      'Aucun achat précédent trouvé pour ce compte.';

  @override
  String get paywallRestoreSuccess =>
      'Achats restaurés. Bienvenue dans Premium !';

  @override
  String get paywallClose => 'Fermer';

  @override
  String playersCapacity(int count, int max) {
    return '$count/$max joueurs (offre gratuite)';
  }

  @override
  String get routeErrorMessage => 'Impossible d\'ouvrir cet écran.';

  @override
  String get cardFree => 'LIBRE';

  @override
  String get inviteDefaultRoomName => 'Salle de Bingo';

  @override
  String get hostSetupErrorEmptyName =>
      'Le nom de la salle ne peut pas être vide.';

  @override
  String get hostSetupErrorNoWifi =>
      'Impossible d\'obtenir l\'adresse Wi-Fi. Vérifiez votre connexion Wi-Fi.';

  @override
  String get hostSetupErrorPortUnavailable =>
      'Aucun port réseau disponible pour créer la salle. Fermez les autres applis qui utilisent le réseau et réessayez.';

  @override
  String get hostSetupErrorUnexpected =>
      'Une erreur est survenue lors de la création de la salle. Réessayez.';

  @override
  String get hostRoomErrorConnection => 'Problème de connexion avec un joueur.';

  @override
  String get hostRoomWinnerTitle => 'BINGO !';

  @override
  String hostRoomWinnerMessage(String name) {
    return '$name a gagné cette manche !';
  }

  @override
  String get hostRoomNewRound => 'Nouvelle manche';

  @override
  String get hostRoomEndRoom => 'Fermer la salle';

  @override
  String get hostRoomWaitingDraw =>
      'Tirez le premier numéro pour commencer la manche.';

  @override
  String get hostRoomRoundOverHint =>
      'Manche terminée. Lancez une nouvelle manche ou fermez la salle.';

  @override
  String drawnCount(int count) {
    return '$count/75 tirés';
  }

  @override
  String get scanErrorInvalidCode =>
      'Code invalide. Demandez un nouveau QR code à l\'hôte.';

  @override
  String get scanErrorRejected =>
      'L\'hôte a refusé la connexion. Vérifiez le réseau Wi-Fi et le code de la salle.';

  @override
  String get scanErrorTimeout =>
      'L\'hôte n\'a pas répondu. Vérifiez que vous êtes sur le même réseau Wi-Fi.';

  @override
  String get scanErrorUnexpected => 'Erreur inattendue en rejoignant la salle.';

  @override
  String get scanErrorNotOnWifi =>
      'Vous n\'êtes pas en Wi-Fi. Connectez-vous au réseau de l\'hôte et réessayez.';

  @override
  String scanErrorDifferentNetwork(String playerIp, String hostIp) {
    return 'Vous semblez être sur un autre réseau (votre IP $playerIp, hôte $hostIp). Rejoignez le réseau Wi-Fi de l\'hôte.';
  }

  @override
  String get scanErrorHostUnreachable =>
      'Impossible de joindre l\'hôte. Vérifiez que vous êtes sur le même réseau Wi-Fi. Les réseaux invités, d\'hôtel ou d\'immeuble bloquent souvent la communication entre appareils ; dans ce cas, utilisez le point d\'accès de l\'hôte.';

  @override
  String get scanErrorRoomClosed =>
      'La salle n\'est plus ouverte. Demandez une nouvelle invitation à l\'hôte.';

  @override
  String get playerGameLastCalled => 'Dernier numéro';

  @override
  String get playerGameNoCallsYet => 'Aucun numéro tiré pour l\'instant';

  @override
  String get connectionConnecting => 'Connexion à l\'hôte...';

  @override
  String get connectionReconnecting => 'Connexion perdue. Reconnexion...';

  @override
  String get connectionDisconnected => 'Déconnecté de l\'hôte.';

  @override
  String get connectionRetry => 'Réessayer';

  @override
  String get playerGameYouWon => 'BINGO ! Vous avez gagné !';

  @override
  String playerGameSomeoneWon(String name) {
    return '$name a gagné cette manche.';
  }

  @override
  String get playerGameWaitNextRound =>
      'Attendez que l\'hôte lance une nouvelle manche ou revenez à l\'accueil.';

  @override
  String get backToLobby => 'Retour à l\'accueil';

  @override
  String get playerGameClaimRejected =>
      'Pas encore de bingo ! Vérifiez votre carte et continuez à jouer.';

  @override
  String get playerGameRoomClosedTitle => 'L\'hôte a fermé la salle';

  @override
  String get playerGameRoomClosedMessage =>
      'La partie est terminée. Merci d\'avoir joué !';

  @override
  String get playerGameLeaveTitle => 'Quitter la partie ?';

  @override
  String get playerGameLeaveMessage =>
      'Vous perdrez votre carte et quitterez la salle.';

  @override
  String get playerGameLeave => 'Quitter';

  @override
  String get playerGameStay => 'Rester';

  @override
  String playerGameShoutCooldown(int seconds) {
    return 'Patientez ${seconds}s';
  }

  @override
  String get inviteShareInvite => 'Partager l\'invitation';

  @override
  String get inviteCopyLink => 'Copier le lien';

  @override
  String get inviteLinkCopied => 'Lien copié !';

  @override
  String invitePasteHint(String button) {
    return 'ou demandez de coller le lien dans « $button »';
  }

  @override
  String get playersCapacityLabel => 'joueurs (offre gratuite)';

  @override
  String get playersConnectedLabel => 'joueurs connectés';

  @override
  String get hostRoomUndoLast => 'Annuler la dernière boule';

  @override
  String hostRoomUndone(String label) {
    return 'Boule $label annulée';
  }

  @override
  String get hostRoomPause => 'Pause';

  @override
  String get hostRoomResume => 'Reprendre';

  @override
  String get hostRoomEmptyTitle => 'Aucune boule';

  @override
  String get tourSkip => 'Passer';

  @override
  String get tourNext => 'Suivant';

  @override
  String get cardCellMarked => 'coché';

  @override
  String get cardCellCalled => 'tiré, non coché';

  @override
  String get cardCellNotCalled => 'non tiré';

  @override
  String get cardCellFreeSpace => 'case gratuite';

  @override
  String get scanCameraDeniedTitle => 'Accès à la caméra requis';

  @override
  String get scanCameraDeniedMessage =>
      'Autorisez l\'accès à la caméra dans les réglages pour lire le QR code, ou saisissez le code manuellement.';

  @override
  String get scanCameraErrorMessage =>
      'Impossible d\'ouvrir la caméra. Réessayez ou saisissez le code manuellement.';

  @override
  String get scanOpenSettings => 'Ouvrir les réglages';

  @override
  String get lobbySettingsButton => 'Paramètres';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsSoundSection => 'Son';

  @override
  String get settingsSoundEffects => 'Effets sonores';

  @override
  String get settingsSoundEffectsSubtitle =>
      'Sons au tirage, au marquage et à la victoire';

  @override
  String get settingsVolume => 'Volume';

  @override
  String get settingsVolumeTest => 'Tester';

  @override
  String get settingsCreditsSection => 'Crédits';

  @override
  String get settingsAudioCredits =>
      'Effets sonores créés pour cette application, sans licence tierce.';

  @override
  String get premiumTitle => 'Votre Premium';

  @override
  String get premiumActiveTitle => 'Premium actif';

  @override
  String get premiumActiveSubtitle =>
      'Merci de soutenir le jeu. Voici ce que vous avez débloqué :';

  @override
  String get premiumManage => 'Gérer l\'abonnement';
}
