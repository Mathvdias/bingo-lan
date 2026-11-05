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
  String get manualGlobe => 'Manual';

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
  String playersInRoom(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count players in the room',
      one: '1 player in the room',
      zero: 'No players in the room',
    );
    return '$_temp0';
  }

  @override
  String get shoutedBingo => 'shouted BINGO!';

  @override
  String get cardId => 'Card ID:';

  @override
  String get manualInputInstruction =>
      'Type the number drawn on the physical globe';

  @override
  String get lobbySubtitle => 'Your party, your rules';

  @override
  String get lobbyWifiShowcase =>
      'Bingo only works locally! Make sure you are on the same Wi-Fi network as your guests.';

  @override
  String get lobbyWifiBannerDefault => 'Play on the host\'s Wi-Fi network!';

  @override
  String get buttonWifi => 'WIFI';

  @override
  String get lobbyHostShowcase =>
      'Click here if YOU are the host and want to draw the bingo balls.';

  @override
  String get lobbyJoinShowcase =>
      'Click here to scan the QR Code and play using a card on your phone.';

  @override
  String get lobbySoloShowcase =>
      'Want to test playing offline alone? Use this mode!';

  @override
  String get soloButton => 'Solo Bingo';

  @override
  String get buttonConfig => 'CONFIG';

  @override
  String get scanWifiBannerDefault => 'Connect to the host\'s Wi-Fi network.';

  @override
  String get scanWifiBannerNoWifi =>
      'You\'re not on Wi-Fi. Connect to the host\'s network.';

  @override
  String scanWifiBannerOnWifi(String ip) {
    return 'Wi-Fi connected ($ip). Use the same network as the host.';
  }

  @override
  String get scanManualButton => 'Enter code';

  @override
  String get revealNetwork => 'Reveal Network';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get aboutDeveloper => 'Developer (GitHub)';

  @override
  String get aboutTitle => 'About Bingo';

  @override
  String get aboutImportantTitle => 'Important: Same Wi-Fi Network';

  @override
  String get aboutImportantBody =>
      'Bingo works over a secure local connection. For players to find your room, EVERYONE (including the host) must be connected to the exact same Wi-Fi network.';

  @override
  String get aboutHowToPlayTitle => 'How to Play (Step by Step)';

  @override
  String get aboutStep1Title => 'Choose the Host';

  @override
  String get aboutStep1Desc =>
      'One person starts the game by clicking \'Host a Bingo\' and shares the Room Code.';

  @override
  String get aboutStep2Title => 'Players in the Room';

  @override
  String get aboutStep2Desc =>
      'Other participants click \'Join\' and type the code (or point their camera at the QR Code).';

  @override
  String get aboutStep3Title => 'Marking the Card';

  @override
  String get aboutStep3Desc =>
      'The host draws the balls. Tap the number on your phone\'s card to mark it.';

  @override
  String get aboutStep4Title => 'BINGO!';

  @override
  String get aboutStep4Desc =>
      'Completed your card? Press the \'SHOUT BINGO\' button before everyone else to win!';

  @override
  String get aboutLanguage => 'Language';

  @override
  String get scanEnterName => 'Enter your name';

  @override
  String get scanJoin => 'Join';

  @override
  String get scanManualTitle => 'Enter Manually';

  @override
  String get scanManualHint => 'Paste the code or room link below:';

  @override
  String get scanCancel => 'Cancel';

  @override
  String get scanShowcaseScanner =>
      'Point your camera at the host\'s QR Code to quickly join the room.';

  @override
  String get inviteRoomCode => 'Room Code';

  @override
  String get inviteTitle => 'Invite Players';

  @override
  String get inviteScanDesc => 'Scan to join the room!';

  @override
  String inviteShareLinkMessage(String qrData) {
    return 'Come play Bingo! Just tap the link from your phone:\n$qrData';
  }

  @override
  String inviteConnectedPlayers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count players connected',
      one: '1 player connected',
      zero: 'No players connected yet',
    );
    return '$_temp0';
  }

  @override
  String get inviteWaitingPlayers => 'Waiting for players...';

  @override
  String get inviteStartBingo => 'Start Bingo!';

  @override
  String get lobbyPremiumTag => 'PREMIUM';

  @override
  String get lobbyUpgradeButton => 'Upgrade';

  @override
  String get playerGameTitle => 'Your Card';

  @override
  String get playerGameShout => 'Shout BINGO!';

  @override
  String get playerScanNameHint => 'E.g. Matthew';

  @override
  String get playerScanTitle => 'Join a Bingo';

  @override
  String get soloGameTitle => 'Solo Bingo';

  @override
  String get soloGameDraw => 'Draw Number';

  @override
  String get hostSetupTitle => 'Host a Bingo';

  @override
  String get hostSetupRoomHint => 'E.g. Uncle Joe\'s Bingo';

  @override
  String get hostSetupCreate => 'Create Room';

  @override
  String get hostSetupNameLabel => 'Name your room';

  @override
  String get hostSetupWifiWarning =>
      'Warning: All players MUST be connected to the SAME WI-FI NETWORK to join the room.';

  @override
  String get hostSetupWifiDesc =>
      'Play with people on the same Wi-Fi network. Ideal for parties and gatherings.';

  @override
  String get playerScanCameraHint => 'Point your camera at the Host\'s QR Code';

  @override
  String get paywallHeroTitle => 'Go Premium';

  @override
  String get paywallHeroSubtitle =>
      'Bigger parties, zero limits, no interruptions.';

  @override
  String get paywallBenefitUnlimitedPlayers => 'Unlimited players per room';

  @override
  String get paywallBenefitAutoGlobe =>
      'Auto globe: the app draws the balls for you';

  @override
  String get paywallBenefitNoAds => 'No ads';

  @override
  String get paywallPeriodWeekly => 'Weekly';

  @override
  String get paywallPeriodMonthly => 'Monthly';

  @override
  String get paywallPeriodTwoMonth => 'Every 2 months';

  @override
  String get paywallPeriodThreeMonth => 'Quarterly';

  @override
  String get paywallPeriodSixMonth => 'Every 6 months';

  @override
  String get paywallPeriodAnnual => 'Annual';

  @override
  String get paywallPeriodLifetime => 'Lifetime';

  @override
  String get paywallPeriodCustom => 'Plan';

  @override
  String get paywallBilledWeekly => 'Billed every week';

  @override
  String get paywallBilledMonthly => 'Billed every month';

  @override
  String get paywallBilledTwoMonth => 'Billed every 2 months';

  @override
  String get paywallBilledThreeMonth => 'Billed every 3 months';

  @override
  String get paywallBilledSixMonth => 'Billed every 6 months';

  @override
  String get paywallBilledAnnual => 'Billed once a year';

  @override
  String get paywallBilledCustom => 'Subscription';

  @override
  String get paywallOneTimePayment => 'One-time payment';

  @override
  String paywallSavings(int percent) {
    return 'Save $percent%';
  }

  @override
  String paywallCta(String price) {
    return 'Continue for $price';
  }

  @override
  String get paywallRestore => 'Restore purchases';

  @override
  String get paywallLegal =>
      'Subscriptions renew automatically unless cancelled at least 24 hours before the end of the current period. Cancel anytime in your store account settings.';

  @override
  String get paywallEmpty => 'No plans available right now.';

  @override
  String get paywallRetry => 'Try again';

  @override
  String get paywallErrorLoad =>
      'We couldn\'t load the plans. Check your connection and try again.';

  @override
  String get paywallErrorPurchase =>
      'The purchase could not be completed. Please try again.';

  @override
  String get paywallErrorRestore =>
      'We couldn\'t restore your purchases. Please try again.';

  @override
  String get paywallRestoreNothing =>
      'No previous purchases were found for this account.';

  @override
  String get paywallRestoreSuccess => 'Purchases restored. Welcome to Premium!';

  @override
  String get paywallClose => 'Close';

  @override
  String playersCapacity(int count, int max) {
    return '$count/$max players (free plan)';
  }

  @override
  String get routeErrorMessage => 'We couldn\'t open this page.';

  @override
  String get cardFree => 'FREE';

  @override
  String get inviteDefaultRoomName => 'Bingo Room';

  @override
  String get hostSetupErrorEmptyName => 'The room name can\'t be empty.';

  @override
  String get hostSetupErrorNoWifi =>
      'We couldn\'t get your Wi-Fi address. Check your Wi-Fi connection.';

  @override
  String get hostSetupErrorPortUnavailable =>
      'No network port is available to host the room. Close other apps using the network and try again.';

  @override
  String get hostSetupErrorUnexpected =>
      'Something went wrong while creating the room. Please try again.';

  @override
  String get hostRoomErrorConnection =>
      'There was a connection problem with a player.';

  @override
  String get hostRoomWinnerTitle => 'BINGO!';

  @override
  String hostRoomWinnerMessage(String name) {
    return '$name won this round!';
  }

  @override
  String get hostRoomNewRound => 'New round';

  @override
  String get hostRoomEndRoom => 'End room';

  @override
  String get hostRoomWaitingDraw => 'Draw the first number to start the round.';

  @override
  String get hostRoomRoundOverHint =>
      'Round over. Start a new round or end the room.';

  @override
  String drawnCount(int count) {
    return '$count/75 drawn';
  }

  @override
  String get scanErrorInvalidCode =>
      'Invalid code. Ask the host for a new QR code.';

  @override
  String get scanErrorRejected =>
      'The host didn\'t accept the connection. Check the Wi-Fi network and the room code.';

  @override
  String get scanErrorTimeout =>
      'The host didn\'t answer. Make sure you\'re on the same Wi-Fi network.';

  @override
  String get scanErrorUnexpected => 'Unexpected error while joining the room.';

  @override
  String get scanErrorNotOnWifi =>
      'You\'re not on Wi-Fi. Connect to the host\'s network and try again.';

  @override
  String scanErrorDifferentNetwork(String playerIp, String hostIp) {
    return 'You seem to be on a different network (your IP $playerIp, host $hostIp). Join the host\'s Wi-Fi network.';
  }

  @override
  String get scanErrorHostUnreachable =>
      'Couldn\'t reach the host. Make sure you\'re on the same Wi-Fi network. Guest, hotel or building networks often block devices from talking to each other; in that case use the host\'s hotspot.';

  @override
  String get scanErrorRoomClosed =>
      'The room is no longer open. Ask the host for a new invite.';

  @override
  String get playerGameLastCalled => 'Last called';

  @override
  String get playerGameNoCallsYet => 'No numbers called yet';

  @override
  String get connectionConnecting => 'Connecting to the host...';

  @override
  String get connectionReconnecting => 'Connection lost. Reconnecting...';

  @override
  String get connectionDisconnected => 'Disconnected from the host.';

  @override
  String get connectionRetry => 'Retry';

  @override
  String get playerGameYouWon => 'BINGO! You won!';

  @override
  String playerGameSomeoneWon(String name) {
    return '$name won this round.';
  }

  @override
  String get playerGameWaitNextRound =>
      'Wait for the host to start a new round, or go back to the lobby.';

  @override
  String get backToLobby => 'Back to lobby';

  @override
  String get playerGameClaimRejected =>
      'Not a bingo yet! Check your card and keep playing.';

  @override
  String get playerGameRoomClosedTitle => 'The host closed the room';

  @override
  String get playerGameRoomClosedMessage =>
      'This game is over. Thanks for playing!';

  @override
  String get playerGameLeaveTitle => 'Leave the game?';

  @override
  String get playerGameLeaveMessage =>
      'You\'ll lose your card and leave the room.';

  @override
  String get playerGameLeave => 'Leave';

  @override
  String get playerGameStay => 'Stay';

  @override
  String playerGameShoutCooldown(int seconds) {
    return 'Wait ${seconds}s';
  }

  @override
  String get inviteShareInvite => 'Share invite';

  @override
  String get inviteCopyLink => 'Copy link';

  @override
  String get inviteLinkCopied => 'Link copied!';

  @override
  String invitePasteHint(String button) {
    return 'or ask them to paste the link under \'$button\'';
  }

  @override
  String get playersCapacityLabel => 'players (free plan)';

  @override
  String get playersConnectedLabel => 'players connected';

  @override
  String get hostRoomUndoLast => 'Undo last ball';

  @override
  String hostRoomUndone(String label) {
    return 'Ball $label undone';
  }

  @override
  String get hostRoomPause => 'Pause';

  @override
  String get hostRoomResume => 'Resume';

  @override
  String get hostRoomEmptyTitle => 'No balls yet';

  @override
  String get tourSkip => 'Skip';

  @override
  String get tourNext => 'Next';

  @override
  String get cardCellMarked => 'marked';

  @override
  String get cardCellCalled => 'called, not marked';

  @override
  String get cardCellNotCalled => 'not called';

  @override
  String get cardCellFreeSpace => 'free space';

  @override
  String get scanCameraDeniedTitle => 'Camera access needed';

  @override
  String get scanCameraDeniedMessage =>
      'Allow camera access in Settings to scan the QR code, or enter the code manually.';

  @override
  String get scanCameraErrorMessage =>
      'We couldn\'t open the camera. Try again or enter the code manually.';

  @override
  String get scanOpenSettings => 'Open Settings';

  @override
  String get lobbySettingsButton => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSoundSection => 'Sound';

  @override
  String get settingsSoundEffects => 'Sound effects';

  @override
  String get settingsSoundEffectsSubtitle => 'Sounds when drawing, marking and winning';

  @override
  String get settingsVolume => 'Volume';

  @override
  String get settingsVolumeTest => 'Test';

  @override
  String get settingsCreditsSection => 'Credits';

  @override
  String get settingsAudioCredits => 'Sound effects made for this app — no third-party licences.';
}
