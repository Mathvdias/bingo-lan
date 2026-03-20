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

  @override
  String get lobbySubtitle => 'Your party, your rules';

  @override
  String get lobbyWifiShowcase =>
      'Bingo only works locally! Make sure you are on the same Wi-Fi network as your guests.';

  @override
  String get lobbyWifiBannerDefault => 'Play on the host\'s Wi-Fi network!';

  @override
  String lobbyWifiBannerConnected(String wifiName) {
    return 'Current network: $wifiName\nPlay on the host\'s network!';
  }

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
  String scanWifiBannerConnected(String wifiName) {
    return 'Network: $wifiName\nConnect to the host\'s network.';
  }

  @override
  String get scanManualButton => 'Enter Code Manually';

  @override
  String get revealNetwork => 'Reveal Network';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfUse => 'Terms of Use';
}
