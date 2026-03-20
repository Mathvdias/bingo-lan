// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Bingo Lucca';

  @override
  String get startBingo => 'Ospita un Bingo';

  @override
  String get joinBingo => 'Unisciti a un Bingo';

  @override
  String get upgrade => 'Aggiorna';

  @override
  String get premiumBadge => 'PREMIUM';

  @override
  String get manualGlobe => 'Manuale (Globo Fisico)';

  @override
  String get virtualGlobe => 'Virtuale';

  @override
  String get autoGlobe => 'Globo Automatico (Premium)';

  @override
  String get drawRandom => 'Estrai (Casuale)';

  @override
  String get confirm => 'Conferma';

  @override
  String get numberInput => 'Numero';

  @override
  String get typeNumberHint => 'Digita il numero estratto';

  @override
  String get errorInvalidNumber => 'Il numero deve essere compreso tra 1 e 75';

  @override
  String get errorNumberDrawn => 'Numero già estratto!';

  @override
  String get paywallTitle => 'Funzione Premium';

  @override
  String get paywallMessage =>
      'Il Globo Automatico è una funzione premium. Aggiorna ora!';

  @override
  String get stopRoomTitle => 'Termina Stanza';

  @override
  String get stopRoomMessage =>
      'Sei sicuro di voler chiudere la stanza? Tutti i giocatori verranno disconnessi.';

  @override
  String get no => 'No';

  @override
  String get yes => 'Sì';

  @override
  String get hostRoomTitle => 'Stanza Bingo (Ospite)';

  @override
  String get playersInRoom => 'giocatori nella stanza';

  @override
  String get shoutedBingo => 'ha gridato BINGO!';

  @override
  String get cardId => 'ID Cartella:';

  @override
  String get manualInputInstruction =>
      'Scrivi il numero estratto sul globo fisico';

  @override
  String get lobbySubtitle => 'La tua festa, le tue regole';

  @override
  String get lobbyWifiShowcase =>
      'Il Bingo funziona solo localmente! Assicurati di essere sulla stessa rete Wi-Fi dei tuoi ospiti.';

  @override
  String get lobbyWifiBannerDefault => 'Gioca sulla rete Wi-Fi dell\'host!';

  @override
  String lobbyWifiBannerConnected(String wifiName) {
    return 'Rete attuale: $wifiName\nGioca sulla rete dell\'host!';
  }

  @override
  String get buttonWifi => 'WIFI';

  @override
  String get lobbyHostShowcase =>
      'Clicca qui se TU sei l\'host e vuoi estrarre i numeri del bingo.';

  @override
  String get lobbyJoinShowcase =>
      'Clicca qui per scansionare il codice QR e giocare con una cartella sul tuo telefono.';

  @override
  String get lobbySoloShowcase =>
      'Vuoi provare a giocare offline da solo? Usa questa modalità!';

  @override
  String get soloButton => 'Bingo Singolo';

  @override
  String get buttonConfig => 'CONFIG';

  @override
  String get scanWifiBannerDefault => 'Connettiti alla rete Wi-Fi dell\'host.';

  @override
  String scanWifiBannerConnected(String wifiName) {
    return 'Rete: $wifiName\nConnettiti alla rete dell\'host.';
  }

  @override
  String get scanManualButton => 'Inserisci Codice Manualmente';

  @override
  String get revealNetwork => 'Rivela Rete';

  @override
  String get privacyPolicy => 'Informativa sulla privacy';

  @override
  String get termsOfUse => 'Termini di utilizzo';
}
