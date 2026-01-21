import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
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
  /// **'Organizar um Bingo'**
  String get startBingo;

  /// No description provided for @joinBingo.
  ///
  /// In en, this message translates to:
  /// **'Entrar em um Bingo'**
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
  /// **'Manual (Físico)'**
  String get manualGlobe;

  /// No description provided for @virtualGlobe.
  ///
  /// In en, this message translates to:
  /// **'Virtual'**
  String get virtualGlobe;

  /// No description provided for @autoGlobe.
  ///
  /// In en, this message translates to:
  /// **'Globo Automático (Premium)'**
  String get autoGlobe;

  /// No description provided for @drawRandom.
  ///
  /// In en, this message translates to:
  /// **'Sortear (Aleatório)'**
  String get drawRandom;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @numberInput.
  ///
  /// In en, this message translates to:
  /// **'Número'**
  String get numberInput;

  /// No description provided for @typeNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Digite o número sorteado'**
  String get typeNumberHint;

  /// No description provided for @errorInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Número deve ser entre 1 e 75'**
  String get errorInvalidNumber;

  /// No description provided for @errorNumberDrawn.
  ///
  /// In en, this message translates to:
  /// **'Número já foi sorteado!'**
  String get errorNumberDrawn;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Recurso Pago'**
  String get paywallTitle;

  /// No description provided for @paywallMessage.
  ///
  /// In en, this message translates to:
  /// **'O Globo Automático é um recurso pago. Faça upgrade!'**
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
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'ja', 'pt'].contains(locale.languageCode);

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
