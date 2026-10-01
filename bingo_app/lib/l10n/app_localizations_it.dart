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
  String get manualGlobe => 'Manuale';

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
  String playersInRoom(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giocatori nella sala',
      one: '1 giocatore nella sala',
      zero: 'Nessun giocatore nella sala',
    );
    return '$_temp0';
  }

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
    return 'Vieni a giocare a Bingo! Basta toccare dal telefono: $qrData';
  }

  @override
  String inviteConnectedPlayers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giocatori connessi',
      one: '1 giocatore connesso',
      zero: 'Nessun giocatore connesso finora',
    );
    return '$_temp0';
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

  @override
  String get splashSubtitle => 'Il modo più divertente di giocare!';

  @override
  String get paywallHeroTitle => 'Passa a Premium';

  @override
  String get paywallHeroSubtitle =>
      'Feste più grandi, senza limiti e senza interruzioni.';

  @override
  String get paywallBenefitUnlimitedPlayers =>
      'Giocatori illimitati per stanza';

  @override
  String get paywallBenefitAutoGlobe =>
      'Globo automatico: l\'app estrae le palline per te';

  @override
  String get paywallBenefitNoAds => 'Senza pubblicità';

  @override
  String get paywallPeriodWeekly => 'Settimanale';

  @override
  String get paywallPeriodMonthly => 'Mensile';

  @override
  String get paywallPeriodTwoMonth => 'Bimestrale';

  @override
  String get paywallPeriodThreeMonth => 'Trimestrale';

  @override
  String get paywallPeriodSixMonth => 'Semestrale';

  @override
  String get paywallPeriodAnnual => 'Annuale';

  @override
  String get paywallPeriodLifetime => 'A vita';

  @override
  String get paywallPeriodCustom => 'Piano';

  @override
  String get paywallBilledWeekly => 'Addebitato ogni settimana';

  @override
  String get paywallBilledMonthly => 'Addebitato ogni mese';

  @override
  String get paywallBilledTwoMonth => 'Addebitato ogni 2 mesi';

  @override
  String get paywallBilledThreeMonth => 'Addebitato ogni 3 mesi';

  @override
  String get paywallBilledSixMonth => 'Addebitato ogni 6 mesi';

  @override
  String get paywallBilledAnnual => 'Addebitato una volta all\'anno';

  @override
  String get paywallBilledCustom => 'Abbonamento';

  @override
  String get paywallOneTimePayment => 'Pagamento unico';

  @override
  String paywallSavings(int percent) {
    return 'Risparmia il $percent%';
  }

  @override
  String paywallCta(String price) {
    return 'Continua per $price';
  }

  @override
  String get paywallRestore => 'Ripristina acquisti';

  @override
  String get paywallLegal =>
      'Gli abbonamenti si rinnovano automaticamente salvo disdetta almeno 24 ore prima della fine del periodo in corso. Annulla quando vuoi nelle impostazioni del tuo account dello store.';

  @override
  String get paywallEmpty => 'Nessun piano disponibile al momento.';

  @override
  String get paywallRetry => 'Riprova';

  @override
  String get paywallErrorLoad =>
      'Impossibile caricare i piani. Controlla la connessione e riprova.';

  @override
  String get paywallErrorPurchase =>
      'Impossibile completare l\'acquisto. Riprova.';

  @override
  String get paywallErrorRestore =>
      'Impossibile ripristinare gli acquisti. Riprova.';

  @override
  String get paywallRestoreNothing =>
      'Nessun acquisto precedente trovato per questo account.';

  @override
  String get paywallRestoreSuccess =>
      'Acquisti ripristinati. Benvenuto in Premium!';

  @override
  String get paywallClose => 'Chiudi';

  @override
  String playersCapacity(int count, int max) {
    return '$count/$max giocatori (piano gratuito)';
  }

  @override
  String get routeErrorMessage => 'Impossibile aprire questa schermata.';

  @override
  String get cardFree => 'LIBERO';

  @override
  String get inviteDefaultRoomName => 'Sala Bingo';

  @override
  String get hostSetupErrorEmptyName =>
      'Il nome della sala non può essere vuoto.';

  @override
  String get hostSetupErrorNoWifi =>
      'Impossibile ottenere l\'indirizzo Wi-Fi. Controlla la connessione Wi-Fi.';

  @override
  String get hostSetupErrorPortUnavailable =>
      'Nessuna porta di rete disponibile per creare la sala. Chiudi le altre app che usano la rete e riprova.';

  @override
  String get hostSetupErrorUnexpected =>
      'Qualcosa è andato storto nella creazione della sala. Riprova.';

  @override
  String get hostRoomErrorConnection =>
      'Problema di connessione con un giocatore.';

  @override
  String get hostRoomWinnerTitle => 'BINGO!';

  @override
  String hostRoomWinnerMessage(String name) {
    return '$name ha vinto questo round!';
  }

  @override
  String get hostRoomNewRound => 'Nuovo round';

  @override
  String get hostRoomEndRoom => 'Chiudi sala';

  @override
  String get hostRoomWaitingDraw =>
      'Estrai il primo numero per iniziare il round.';

  @override
  String get hostRoomRoundOverHint =>
      'Round terminato. Inizia un nuovo round o chiudi la sala.';

  @override
  String drawnCount(int count) {
    return '$count/75 estratti';
  }

  @override
  String get scanErrorInvalidCode =>
      'Codice non valido. Chiedi un nuovo codice QR all\'host.';

  @override
  String get scanErrorRejected =>
      'L\'host non ha accettato la connessione. Controlla la rete Wi-Fi e il codice della sala.';

  @override
  String get scanErrorTimeout =>
      'L\'host non ha risposto. Assicurati di essere sulla stessa rete Wi-Fi.';

  @override
  String get scanErrorUnexpected => 'Errore inatteso nell\'entrare nella sala.';

  @override
  String get playerGameLastCalled => 'Ultimo numero';

  @override
  String get playerGameNoCallsYet => 'Nessun numero estratto finora';

  @override
  String get connectionConnecting => 'Connessione all\'host...';

  @override
  String get connectionReconnecting => 'Connessione persa. Riconnessione...';

  @override
  String get connectionDisconnected => 'Disconnesso dall\'host.';

  @override
  String get connectionRetry => 'Riprova';

  @override
  String get playerGameYouWon => 'BINGO! Hai vinto!';

  @override
  String playerGameSomeoneWon(String name) {
    return '$name ha vinto questo round.';
  }

  @override
  String get playerGameWaitNextRound =>
      'Aspetta che l\'host inizi un nuovo round o torna alla home.';

  @override
  String get backToLobby => 'Torna alla home';

  @override
  String get playerGameClaimRejected =>
      'Non è ancora bingo! Controlla la tua cartella e continua a giocare.';

  @override
  String get playerGameRoomClosedTitle => 'L\'host ha chiuso la sala';

  @override
  String get playerGameRoomClosedMessage =>
      'La partita è finita. Grazie per aver giocato!';

  @override
  String get playerGameLeaveTitle => 'Uscire dalla partita?';

  @override
  String get playerGameLeaveMessage =>
      'Perderai la tua cartella e uscirai dalla sala.';

  @override
  String get playerGameLeave => 'Esci';

  @override
  String get playerGameStay => 'Resta';

  @override
  String playerGameShoutCooldown(int seconds) {
    return 'Attendi ${seconds}s';
  }

  @override
  String get inviteShareInvite => 'Condividi invito';

  @override
  String get inviteCopyLink => 'Copia link';

  @override
  String get inviteLinkCopied => 'Link copiato!';

  @override
  String invitePasteHint(String button) {
    return 'oppure chiedi di incollare il link in \'$button\'';
  }

  @override
  String get playersCapacityLabel => 'giocatori (piano gratuito)';

  @override
  String get playersConnectedLabel => 'giocatori connessi';

  @override
  String get hostRoomUndoLast => 'Annulla ultima pallina';

  @override
  String hostRoomUndone(String label) {
    return 'Pallina $label annullata';
  }

  @override
  String get hostRoomPause => 'Pausa';

  @override
  String get hostRoomResume => 'Riprendi';

  @override
  String get hostRoomEmptyTitle => 'Nessuna pallina';

  @override
  String get tourSkip => 'Salta';

  @override
  String get tourNext => 'Avanti';

  @override
  String get cardCellMarked => 'segnato';

  @override
  String get cardCellCalled => 'estratto, non segnato';

  @override
  String get cardCellNotCalled => 'non estratto';

  @override
  String get cardCellFreeSpace => 'casella libera';

  @override
  String get scanCameraDeniedTitle => 'Accesso alla fotocamera negato';

  @override
  String get scanCameraDeniedMessage =>
      'Consenti l\'accesso alla fotocamera nelle impostazioni per leggere il QR code, oppure inserisci il codice manualmente.';

  @override
  String get scanCameraErrorMessage =>
      'Impossibile aprire la fotocamera. Riprova o inserisci il codice manualmente.';

  @override
  String get scanOpenSettings => 'Apri impostazioni';

  @override
  String inviteConnectedPlayersCapacity(int count, int max) {
    return 'Giocatori connessi: $count/$max gratis';
  }
}
