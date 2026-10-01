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
  /// **'Manual'**
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
  /// **'{count, plural, =0{No players in the room} =1{1 player in the room} other{{count} players in the room}}'**
  String playersInRoom(int count);

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

  /// No description provided for @scanWifiBannerNoWifi.
  ///
  /// In en, this message translates to:
  /// **'You\'re not on Wi-Fi. Connect to the host\'s network.'**
  String get scanWifiBannerNoWifi;

  /// No description provided for @scanWifiBannerOnWifi.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi connected ({ip}). Use the same network as the host.'**
  String scanWifiBannerOnWifi(String ip);

  /// No description provided for @scanManualButton.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
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
  /// **'Important: Same Wi-Fi Network'**
  String get aboutImportantTitle;

  /// No description provided for @aboutImportantBody.
  ///
  /// In en, this message translates to:
  /// **'Bingo works over a secure local connection. For players to find your room, EVERYONE (including the host) must be connected to the exact same Wi-Fi network.'**
  String get aboutImportantBody;

  /// No description provided for @aboutHowToPlayTitle.
  ///
  /// In en, this message translates to:
  /// **'How to Play (Step by Step)'**
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
  /// **'Language'**
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

  /// No description provided for @inviteShareLinkMessage.
  ///
  /// In en, this message translates to:
  /// **'Come play Bingo! Just tap the link from your phone:\n{qrData}'**
  String inviteShareLinkMessage(String qrData);

  /// No description provided for @inviteConnectedPlayers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No players connected yet} =1{1 player connected} other{{count} players connected}}'**
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

  /// No description provided for @paywallHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get paywallHeroTitle;

  /// No description provided for @paywallHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bigger parties, zero limits, no interruptions.'**
  String get paywallHeroSubtitle;

  /// No description provided for @paywallBenefitUnlimitedPlayers.
  ///
  /// In en, this message translates to:
  /// **'Unlimited players per room'**
  String get paywallBenefitUnlimitedPlayers;

  /// No description provided for @paywallBenefitAutoGlobe.
  ///
  /// In en, this message translates to:
  /// **'Auto globe: the app draws the balls for you'**
  String get paywallBenefitAutoGlobe;

  /// No description provided for @paywallBenefitNoAds.
  ///
  /// In en, this message translates to:
  /// **'No ads'**
  String get paywallBenefitNoAds;

  /// No description provided for @paywallPeriodWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get paywallPeriodWeekly;

  /// No description provided for @paywallPeriodMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get paywallPeriodMonthly;

  /// No description provided for @paywallPeriodTwoMonth.
  ///
  /// In en, this message translates to:
  /// **'Every 2 months'**
  String get paywallPeriodTwoMonth;

  /// No description provided for @paywallPeriodThreeMonth.
  ///
  /// In en, this message translates to:
  /// **'Quarterly'**
  String get paywallPeriodThreeMonth;

  /// No description provided for @paywallPeriodSixMonth.
  ///
  /// In en, this message translates to:
  /// **'Every 6 months'**
  String get paywallPeriodSixMonth;

  /// No description provided for @paywallPeriodAnnual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get paywallPeriodAnnual;

  /// No description provided for @paywallPeriodLifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get paywallPeriodLifetime;

  /// No description provided for @paywallPeriodCustom.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get paywallPeriodCustom;

  /// No description provided for @paywallBilledWeekly.
  ///
  /// In en, this message translates to:
  /// **'Billed every week'**
  String get paywallBilledWeekly;

  /// No description provided for @paywallBilledMonthly.
  ///
  /// In en, this message translates to:
  /// **'Billed every month'**
  String get paywallBilledMonthly;

  /// No description provided for @paywallBilledTwoMonth.
  ///
  /// In en, this message translates to:
  /// **'Billed every 2 months'**
  String get paywallBilledTwoMonth;

  /// No description provided for @paywallBilledThreeMonth.
  ///
  /// In en, this message translates to:
  /// **'Billed every 3 months'**
  String get paywallBilledThreeMonth;

  /// No description provided for @paywallBilledSixMonth.
  ///
  /// In en, this message translates to:
  /// **'Billed every 6 months'**
  String get paywallBilledSixMonth;

  /// No description provided for @paywallBilledAnnual.
  ///
  /// In en, this message translates to:
  /// **'Billed once a year'**
  String get paywallBilledAnnual;

  /// No description provided for @paywallBilledCustom.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get paywallBilledCustom;

  /// No description provided for @paywallOneTimePayment.
  ///
  /// In en, this message translates to:
  /// **'One-time payment'**
  String get paywallOneTimePayment;

  /// No description provided for @paywallSavings.
  ///
  /// In en, this message translates to:
  /// **'Save {percent}%'**
  String paywallSavings(int percent);

  /// No description provided for @paywallCta.
  ///
  /// In en, this message translates to:
  /// **'Continue for {price}'**
  String paywallCta(String price);

  /// No description provided for @paywallRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get paywallRestore;

  /// No description provided for @paywallLegal.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions renew automatically unless cancelled at least 24 hours before the end of the current period. Cancel anytime in your store account settings.'**
  String get paywallLegal;

  /// No description provided for @paywallEmpty.
  ///
  /// In en, this message translates to:
  /// **'No plans available right now.'**
  String get paywallEmpty;

  /// No description provided for @paywallRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get paywallRetry;

  /// No description provided for @paywallErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load the plans. Check your connection and try again.'**
  String get paywallErrorLoad;

  /// No description provided for @paywallErrorPurchase.
  ///
  /// In en, this message translates to:
  /// **'The purchase could not be completed. Please try again.'**
  String get paywallErrorPurchase;

  /// No description provided for @paywallErrorRestore.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t restore your purchases. Please try again.'**
  String get paywallErrorRestore;

  /// No description provided for @paywallRestoreNothing.
  ///
  /// In en, this message translates to:
  /// **'No previous purchases were found for this account.'**
  String get paywallRestoreNothing;

  /// No description provided for @paywallRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored. Welcome to Premium!'**
  String get paywallRestoreSuccess;

  /// No description provided for @paywallClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get paywallClose;

  /// No description provided for @playersCapacity.
  ///
  /// In en, this message translates to:
  /// **'{count}/{max} players (free plan)'**
  String playersCapacity(int count, int max);

  /// No description provided for @routeErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t open this page.'**
  String get routeErrorMessage;

  /// No description provided for @cardFree.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get cardFree;

  /// No description provided for @inviteDefaultRoomName.
  ///
  /// In en, this message translates to:
  /// **'Bingo Room'**
  String get inviteDefaultRoomName;

  /// No description provided for @hostSetupErrorEmptyName.
  ///
  /// In en, this message translates to:
  /// **'The room name can\'t be empty.'**
  String get hostSetupErrorEmptyName;

  /// No description provided for @hostSetupErrorNoWifi.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t get your Wi-Fi address. Check your Wi-Fi connection.'**
  String get hostSetupErrorNoWifi;

  /// No description provided for @hostSetupErrorPortUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No network port is available to host the room. Close other apps using the network and try again.'**
  String get hostSetupErrorPortUnavailable;

  /// No description provided for @hostSetupErrorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while creating the room. Please try again.'**
  String get hostSetupErrorUnexpected;

  /// No description provided for @hostRoomErrorConnection.
  ///
  /// In en, this message translates to:
  /// **'There was a connection problem with a player.'**
  String get hostRoomErrorConnection;

  /// No description provided for @hostRoomWinnerTitle.
  ///
  /// In en, this message translates to:
  /// **'BINGO!'**
  String get hostRoomWinnerTitle;

  /// No description provided for @hostRoomWinnerMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} won this round!'**
  String hostRoomWinnerMessage(String name);

  /// No description provided for @hostRoomNewRound.
  ///
  /// In en, this message translates to:
  /// **'New round'**
  String get hostRoomNewRound;

  /// No description provided for @hostRoomEndRoom.
  ///
  /// In en, this message translates to:
  /// **'End room'**
  String get hostRoomEndRoom;

  /// No description provided for @hostRoomWaitingDraw.
  ///
  /// In en, this message translates to:
  /// **'Draw the first number to start the round.'**
  String get hostRoomWaitingDraw;

  /// No description provided for @hostRoomRoundOverHint.
  ///
  /// In en, this message translates to:
  /// **'Round over. Start a new round or end the room.'**
  String get hostRoomRoundOverHint;

  /// No description provided for @drawnCount.
  ///
  /// In en, this message translates to:
  /// **'{count}/75 drawn'**
  String drawnCount(int count);

  /// No description provided for @scanErrorInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid code. Ask the host for a new QR code.'**
  String get scanErrorInvalidCode;

  /// No description provided for @scanErrorRejected.
  ///
  /// In en, this message translates to:
  /// **'The host didn\'t accept the connection. Check the Wi-Fi network and the room code.'**
  String get scanErrorRejected;

  /// No description provided for @scanErrorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The host didn\'t answer. Make sure you\'re on the same Wi-Fi network.'**
  String get scanErrorTimeout;

  /// No description provided for @scanErrorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error while joining the room.'**
  String get scanErrorUnexpected;

  /// No description provided for @scanErrorNotOnWifi.
  ///
  /// In en, this message translates to:
  /// **'You\'re not on Wi-Fi. Connect to the host\'s network and try again.'**
  String get scanErrorNotOnWifi;

  /// No description provided for @scanErrorDifferentNetwork.
  ///
  /// In en, this message translates to:
  /// **'You seem to be on a different network (your IP {playerIp}, host {hostIp}). Join the host\'s Wi-Fi network.'**
  String scanErrorDifferentNetwork(String playerIp, String hostIp);

  /// No description provided for @scanErrorHostUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the host. Make sure you\'re on the same Wi-Fi network. Guest, hotel or building networks often block devices from talking to each other; in that case use the host\'s hotspot.'**
  String get scanErrorHostUnreachable;

  /// No description provided for @scanErrorRoomClosed.
  ///
  /// In en, this message translates to:
  /// **'The room is no longer open. Ask the host for a new invite.'**
  String get scanErrorRoomClosed;

  /// No description provided for @playerGameLastCalled.
  ///
  /// In en, this message translates to:
  /// **'Last called'**
  String get playerGameLastCalled;

  /// No description provided for @playerGameNoCallsYet.
  ///
  /// In en, this message translates to:
  /// **'No numbers called yet'**
  String get playerGameNoCallsYet;

  /// No description provided for @connectionConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting to the host...'**
  String get connectionConnecting;

  /// No description provided for @connectionReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Connection lost. Reconnecting...'**
  String get connectionReconnecting;

  /// No description provided for @connectionDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected from the host.'**
  String get connectionDisconnected;

  /// No description provided for @connectionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get connectionRetry;

  /// No description provided for @playerGameYouWon.
  ///
  /// In en, this message translates to:
  /// **'BINGO! You won!'**
  String get playerGameYouWon;

  /// No description provided for @playerGameSomeoneWon.
  ///
  /// In en, this message translates to:
  /// **'{name} won this round.'**
  String playerGameSomeoneWon(String name);

  /// No description provided for @playerGameWaitNextRound.
  ///
  /// In en, this message translates to:
  /// **'Wait for the host to start a new round, or go back to the lobby.'**
  String get playerGameWaitNextRound;

  /// No description provided for @backToLobby.
  ///
  /// In en, this message translates to:
  /// **'Back to lobby'**
  String get backToLobby;

  /// No description provided for @playerGameClaimRejected.
  ///
  /// In en, this message translates to:
  /// **'Not a bingo yet! Check your card and keep playing.'**
  String get playerGameClaimRejected;

  /// No description provided for @playerGameRoomClosedTitle.
  ///
  /// In en, this message translates to:
  /// **'The host closed the room'**
  String get playerGameRoomClosedTitle;

  /// No description provided for @playerGameRoomClosedMessage.
  ///
  /// In en, this message translates to:
  /// **'This game is over. Thanks for playing!'**
  String get playerGameRoomClosedMessage;

  /// No description provided for @playerGameLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave the game?'**
  String get playerGameLeaveTitle;

  /// No description provided for @playerGameLeaveMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ll lose your card and leave the room.'**
  String get playerGameLeaveMessage;

  /// No description provided for @playerGameLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get playerGameLeave;

  /// No description provided for @playerGameStay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get playerGameStay;

  /// No description provided for @playerGameShoutCooldown.
  ///
  /// In en, this message translates to:
  /// **'Wait {seconds}s'**
  String playerGameShoutCooldown(int seconds);

  /// No description provided for @inviteShareInvite.
  ///
  /// In en, this message translates to:
  /// **'Share invite'**
  String get inviteShareInvite;

  /// No description provided for @inviteCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get inviteCopyLink;

  /// No description provided for @inviteLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied!'**
  String get inviteLinkCopied;

  /// No description provided for @invitePasteHint.
  ///
  /// In en, this message translates to:
  /// **'or ask them to paste the link under \'{button}\''**
  String invitePasteHint(String button);

  /// No description provided for @playersCapacityLabel.
  ///
  /// In en, this message translates to:
  /// **'players (free plan)'**
  String get playersCapacityLabel;

  /// No description provided for @playersConnectedLabel.
  ///
  /// In en, this message translates to:
  /// **'players connected'**
  String get playersConnectedLabel;

  /// No description provided for @hostRoomUndoLast.
  ///
  /// In en, this message translates to:
  /// **'Undo last ball'**
  String get hostRoomUndoLast;

  /// No description provided for @hostRoomUndone.
  ///
  /// In en, this message translates to:
  /// **'Ball {label} undone'**
  String hostRoomUndone(String label);

  /// No description provided for @hostRoomPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get hostRoomPause;

  /// No description provided for @hostRoomResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get hostRoomResume;

  /// No description provided for @hostRoomEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No balls yet'**
  String get hostRoomEmptyTitle;

  /// No description provided for @tourSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get tourSkip;

  /// No description provided for @tourNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get tourNext;

  /// No description provided for @cardCellMarked.
  ///
  /// In en, this message translates to:
  /// **'marked'**
  String get cardCellMarked;

  /// No description provided for @cardCellCalled.
  ///
  /// In en, this message translates to:
  /// **'called, not marked'**
  String get cardCellCalled;

  /// No description provided for @cardCellNotCalled.
  ///
  /// In en, this message translates to:
  /// **'not called'**
  String get cardCellNotCalled;

  /// No description provided for @cardCellFreeSpace.
  ///
  /// In en, this message translates to:
  /// **'free space'**
  String get cardCellFreeSpace;

  /// No description provided for @scanCameraDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera access needed'**
  String get scanCameraDeniedTitle;

  /// No description provided for @scanCameraDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Allow camera access in Settings to scan the QR code, or enter the code manually.'**
  String get scanCameraDeniedMessage;

  /// No description provided for @scanCameraErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t open the camera. Try again or enter the code manually.'**
  String get scanCameraErrorMessage;

  /// No description provided for @scanOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get scanOpenSettings;
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
