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

  @override
  String get aboutDeveloper => 'Sviluppatore (GitHub)';

  @override
  String get aboutTitle => 'Informazioni sul Bingo';

  @override
  String get aboutImportantTitle => '⚠️ Importante: Stessa Rete Wi-Fi';

  @override
  String get aboutImportantBody =>
      'Il Bingo funziona tramite una connessione locale sicura. Affinché i giocatori trovino la tua stanza, TUTTI (incluso l\'host) devono essere connessi alla stessa rete Wi-Fi.';

  @override
  String get aboutHowToPlayTitle => '📖 Come Giocare (Passo dopo Passo)';

  @override
  String get aboutStep1Title => 'Scegli l\'Host';

  @override
  String get aboutStep1Desc =>
      'Una persona inizia la partita cliccando su \'Organizza un Bingo\' e condivide il Codice della Stanza.';

  @override
  String get aboutStep2Title => 'Giocatori nella Stanza';

  @override
  String get aboutStep2Desc =>
      'Gli altri partecipanti cliccano su \'Entra\' e digitano il codice (o puntano la fotocamera sul Codice QR).';

  @override
  String get aboutStep3Title => 'Marcare la Cartella';

  @override
  String get aboutStep3Desc =>
      'L\'host estrae le palline. Tocca il numero sulla cartella del tuo telefono per marcarlo.';

  @override
  String get aboutStep4Title => 'BINGO!';

  @override
  String get aboutStep4Desc =>
      'Cartella completata? Premi il pulsante \'GRIDA BINGO\' prima di tutti per vincere!';

  @override
  String get aboutLanguage => '🌐 Lingua';

  @override
  String get scanEnterName => 'Inserisci il tuo nome';

  @override
  String get scanJoin => 'Entra';

  @override
  String get scanManualTitle => 'Inserisci Manualmente';

  @override
  String get scanManualHint =>
      'Incolla il codice o il link della stanza qui sotto:';

  @override
  String get scanCancel => 'Annulla';

  @override
  String get scanShowcaseScanner =>
      'Punta la fotocamera sul Codice QR dell\'host per unirti rapidamente alla stanza.';

  @override
  String get inviteRoomCode => 'Codice della Stanza';

  @override
  String get inviteShareLink => 'Condividi Link di Invito';

  @override
  String get inviteTitle => 'Invita Giocatori';

  @override
  String get inviteScanDesc => 'Scansiona per unirti alla stanza!';

  @override
  String inviteShareCodeMessage(String qrData) {
    return 'Giochiamo a Bingo! Il nostro codice stanza è: $qrData';
  }

  @override
  String get inviteShareCodeTooltip => 'Condividi Codice';

  @override
  String inviteShareLinkMessage(String qrData) {
    return 'Vieni a giocare a Bingo! Clicca dal tuo telefono: bingo://room/$qrData';
  }

  @override
  String inviteConnectedPlayers(int count) {
    return 'Giocatori Connessi: $count';
  }

  @override
  String get inviteWaitingPlayers => 'In attesa di giocatori...';

  @override
  String get inviteStartBingo => 'Inizia Bingo!';

  @override
  String get lobbyPremiumTag => 'PREMIUM';

  @override
  String get lobbyUpgradeButton => 'Potenzia';

  @override
  String get playerGameTitle => 'La Tua Cartella';

  @override
  String get playerGameShout => 'Urla BINGO!';

  @override
  String get playerScanNameHint => 'Es: Matteo';

  @override
  String get playerScanTitle => 'Partecipa a un Bingo';

  @override
  String get soloGameTitle => 'Bingo Singolo';

  @override
  String get soloGameDraw => 'Estrai Numero';

  @override
  String get hostSetupTitle => 'Ospitare un Bingo';

  @override
  String get hostSetupRoomHint => 'Es: Bingo dello Zio Joe';

  @override
  String get hostSetupCreate => 'Crea Stanza';

  @override
  String get hostSetupNameLabel => 'Dai un nome alla stanza';

  @override
  String get hostSetupWifiWarning =>
      'Avviso: Tutti i giocatori DEVONO essere connessi alla STESSA RETE WI-FI per unirsi alla stanza.';

  @override
  String get hostSetupWifiDesc =>
      'Gioca con persone sulla stessa rete Wi-Fi. Ideale per feste e riunioni.';

  @override
  String get playerScanCameraHint =>
      'Punta la tua fotocamera sul codice QR dell\'Host';
}
