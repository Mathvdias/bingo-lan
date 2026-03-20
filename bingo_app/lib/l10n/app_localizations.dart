import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Bingo Lucca'**
  String get appTitle;

  /// No description provided for @startBingo.
  ///
  /// In en, this message translates to:
  /// **'Host a Bingo'**
  String get startBingo;

  /// No description provided for @joinBingo.
  ///
  /// In en, this message translates to:
  /// **'Join a Bingo'**
  String get joinBingo;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @premiumBadge.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM'**
  String get premiumBadge;

  /// No description provided for @manualGlobe.
  ///
  /// In en, this message translates to:
  /// **'Manual (Physical Globe)'**
  String get manualGlobe;

  /// No description provided for @virtualGlobe.
  ///
  /// In en, this message translates to:
  /// **'Virtual'**
  String get virtualGlobe;

  /// No description provided for @autoGlobe.
  ///
  /// In en, this message translates to:
  /// **'Auto Globe (Premium)'**
  String get autoGlobe;

  /// No description provided for @drawRandom.
  ///
  /// In en, this message translates to:
  /// **'Draw (Random)'**
  String get drawRandom;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @numberInput.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get numberInput;

  /// No description provided for @typeNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Type the drawn number'**
  String get typeNumberHint;

  /// No description provided for @errorInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Number must be between 1 and 75'**
  String get errorInvalidNumber;

  /// No description provided for @errorNumberDrawn.
  ///
  /// In en, this message translates to:
  /// **'Number already drawn!'**
  String get errorNumberDrawn;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Feature'**
  String get paywallTitle;

  /// No description provided for @paywallMessage.
  ///
  /// In en, this message translates to:
  /// **'Auto Globe is a premium feature. Upgrade now!'**
  String get paywallMessage;

  /// No description provided for @stopRoomTitle.
  ///
  /// In en, this message translates to:
  /// **'End Room'**
  String get stopRoomTitle;

  /// No description provided for @stopRoomMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close the room? All players will be disconnected.'**
  String get stopRoomMessage;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @hostRoomTitle.
  ///
  /// In en, this message translates to:
  /// **'Bingo Room (Host)'**
  String get hostRoomTitle;

  /// No description provided for @playersInRoom.
  ///
  /// In en, this message translates to:
  /// **'players in room'**
  String get playersInRoom;

  /// No description provided for @shoutedBingo.
  ///
  /// In en, this message translates to:
  /// **'shouted BINGO!'**
  String get shoutedBingo;

  /// No description provided for @cardId.
  ///
  /// In en, this message translates to:
  /// **'Card ID:'**
  String get cardId;

  /// No description provided for @manualInputInstruction.
  ///
  /// In en, this message translates to:
  /// **'Type the number drawn on the physical globe'**
  String get manualInputInstruction;

  /// No description provided for @lobbySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your party, your rules'**
  String get lobbySubtitle;

  /// No description provided for @lobbyWifiShowcase.
  ///
  /// In en, this message translates to:
  /// **'Bingo only works locally! Make sure you are on the same Wi-Fi network as your guests.'**
  String get lobbyWifiShowcase;

  /// No description provided for @lobbyWifiBannerDefault.
  ///
  /// In en, this message translates to:
  /// **'Play on the host\'s Wi-Fi network!'**
  String get lobbyWifiBannerDefault;

  /// No description provided for @lobbyWifiBannerConnected.
  ///
  /// In en, this message translates to:
  /// **'Current network: {wifiName}\nPlay on the host\'s network!'**
  String lobbyWifiBannerConnected(String wifiName);

  /// No description provided for @buttonWifi.
  ///
  /// In en, this message translates to:
  /// **'WIFI'**
  String get buttonWifi;

  /// No description provided for @lobbyHostShowcase.
  ///
  /// In en, this message translates to:
  /// **'Click here if YOU are the host and want to draw the bingo balls.'**
  String get lobbyHostShowcase;

  /// No description provided for @lobbyJoinShowcase.
  ///
  /// In en, this message translates to:
  /// **'Click here to scan the QR Code and play using a card on your phone.'**
  String get lobbyJoinShowcase;

  /// No description provided for @lobbySoloShowcase.
  ///
  /// In en, this message translates to:
  /// **'Want to test playing offline alone? Use this mode!'**
  String get lobbySoloShowcase;

  /// No description provided for @soloButton.
  ///
  /// In en, this message translates to:
  /// **'Solo Bingo'**
  String get soloButton;

  /// No description provided for @buttonConfig.
  ///
  /// In en, this message translates to:
  /// **'CONFIG'**
  String get buttonConfig;

  /// No description provided for @scanWifiBannerDefault.
  ///
  /// In en, this message translates to:
  /// **'Connect to the host\'s Wi-Fi network.'**
  String get scanWifiBannerDefault;

  /// No description provided for @scanWifiBannerConnected.
  ///
  /// In en, this message translates to:
  /// **'Network: {wifiName}\nConnect to the host\'s network.'**
  String scanWifiBannerConnected(String wifiName);

  /// No description provided for @scanManualButton.
  ///
  /// In en, this message translates to:
  /// **'Enter Code Manually'**
  String get scanManualButton;

  /// No description provided for @revealNetwork.
  ///
  /// In en, this message translates to:
  /// **'Reveal Network'**
  String get revealNetwork;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @aboutDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer (GitHub)'**
  String get aboutDeveloper;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About Bingo'**
  String get aboutTitle;

  /// No description provided for @aboutImportantTitle.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Important: Same Wi-Fi Network'**
  String get aboutImportantTitle;

  /// No description provided for @aboutImportantBody.
  ///
  /// In en, this message translates to:
  /// **'Bingo works over a secure local connection. For players to find your room, EVERYONE (including the host) must be connected to the exact same Wi-Fi network.'**
  String get aboutImportantBody;

  /// No description provided for @aboutHowToPlayTitle.
  ///
  /// In en, this message translates to:
  /// **'📖 How to Play (Step by Step)'**
  String get aboutHowToPlayTitle;

  /// No description provided for @aboutStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Choose the Host'**
  String get aboutStep1Title;

  /// No description provided for @aboutStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'One person starts the game by clicking \'Host a Bingo\' and shares the Room Code.'**
  String get aboutStep1Desc;

  /// No description provided for @aboutStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Players in the Room'**
  String get aboutStep2Title;

  /// No description provided for @aboutStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Other participants click \'Join\' and type the code (or point their camera at the QR Code).'**
  String get aboutStep2Desc;

  /// No description provided for @aboutStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Marking the Card'**
  String get aboutStep3Title;

  /// No description provided for @aboutStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'The host draws the balls. Tap the number on your phone\'s card to mark it.'**
  String get aboutStep3Desc;

  /// No description provided for @aboutStep4Title.
  ///
  /// In en, this message translates to:
  /// **'BINGO!'**
  String get aboutStep4Title;

  /// No description provided for @aboutStep4Desc.
  ///
  /// In en, this message translates to:
  /// **'Completed your card? Press the \'SHOUT BINGO\' button before everyone else to win!'**
  String get aboutStep4Desc;

  /// No description provided for @aboutLanguage.
  ///
  /// In en, this message translates to:
  /// **'🌐 Language'**
  String get aboutLanguage;

  /// No description provided for @scanEnterName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get scanEnterName;

  /// No description provided for @scanJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get scanJoin;

  /// No description provided for @scanManualTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Manually'**
  String get scanManualTitle;

  /// No description provided for @scanManualHint.
  ///
  /// In en, this message translates to:
  /// **'Paste the code or room link below:'**
  String get scanManualHint;

  /// No description provided for @scanCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get scanCancel;

  /// No description provided for @scanShowcaseScanner.
  ///
  /// In en, this message translates to:
  /// **'Point your camera at the host\'s QR Code to quickly join the room.'**
  String get scanShowcaseScanner;

  /// No description provided for @inviteRoomCode.
  ///
  /// In en, this message translates to:
  /// **'Room Code'**
  String get inviteRoomCode;

  /// No description provided for @inviteShareLink.
  ///
  /// In en, this message translates to:
  /// **'Share Invite Link'**
  String get inviteShareLink;

  /// No description provided for @inviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite Players'**
  String get inviteTitle;

  /// No description provided for @inviteScanDesc.
  ///
  /// In en, this message translates to:
  /// **'Scan to join the room!'**
  String get inviteScanDesc;

  /// No description provided for @inviteShareCodeMessage.
  ///
  /// In en, this message translates to:
  /// **'Let\'s play Bingo! Our room code is: {qrData}'**
  String inviteShareCodeMessage(String qrData);

  /// No description provided for @inviteShareCodeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Share Code'**
  String get inviteShareCodeTooltip;

  /// No description provided for @inviteShareLinkMessage.
  ///
  /// In en, this message translates to:
  /// **'Come play Bingo! Just click from your phone: bingo://room/{qrData}'**
  String inviteShareLinkMessage(String qrData);

  /// No description provided for @inviteConnectedPlayers.
  ///
  /// In en, this message translates to:
  /// **'Connected Players: {count}'**
  String inviteConnectedPlayers(int count);

  /// No description provided for @inviteWaitingPlayers.
  ///
  /// In en, this message translates to:
  /// **'Waiting for players...'**
  String get inviteWaitingPlayers;

  /// No description provided for @inviteStartBingo.
  ///
  /// In en, this message translates to:
  /// **'Start Bingo!'**
  String get inviteStartBingo;

  /// No description provided for @lobbyPremiumTag.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM'**
  String get lobbyPremiumTag;

  /// No description provided for @lobbyUpgradeButton.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get lobbyUpgradeButton;

  /// No description provided for @playerGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Card'**
  String get playerGameTitle;

  /// No description provided for @playerGameShout.
  ///
  /// In en, this message translates to:
  /// **'Shout BINGO!'**
  String get playerGameShout;

  /// No description provided for @playerScanNameHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. Matthew'**
  String get playerScanNameHint;

  /// No description provided for @playerScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Join a Bingo'**
  String get playerScanTitle;

  /// No description provided for @soloGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Solo Bingo'**
  String get soloGameTitle;

  /// No description provided for @soloGameDraw.
  ///
  /// In en, this message translates to:
  /// **'Draw Number'**
  String get soloGameDraw;

  /// No description provided for @hostSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Host a Bingo'**
  String get hostSetupTitle;

  /// No description provided for @hostSetupRoomHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. Uncle Joe\'s Bingo'**
  String get hostSetupRoomHint;

  /// No description provided for @hostSetupCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Room'**
  String get hostSetupCreate;

  /// No description provided for @hostSetupNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name your room'**
  String get hostSetupNameLabel;

  /// No description provided for @hostSetupWifiWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: All players MUST be connected to the SAME WI-FI NETWORK to join the room.'**
  String get hostSetupWifiWarning;

  /// No description provided for @hostSetupWifiDesc.
  ///
  /// In en, this message translates to:
  /// **'Play with people on the same Wi-Fi network. Ideal for parties and gatherings.'**
  String get hostSetupWifiDesc;

  /// No description provided for @playerScanCameraHint.
  ///
  /// In en, this message translates to:
  /// **'Point your camera at the Host\'s QR Code'**
  String get playerScanCameraHint;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The most fun way to play!'**
  String get splashSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
