// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Bingo Lucca';

  @override
  String get startBingo => 'Organizar un Bingo';

  @override
  String get joinBingo => 'Unirse a un Bingo';

  @override
  String get upgrade => 'Mejorar Cuenta';

  @override
  String get premiumBadge => 'PREMIUM';

  @override
  String get manualGlobe => 'Manual (Físico)';

  @override
  String get virtualGlobe => 'Virtual';

  @override
  String get autoGlobe => 'Globo Automático (Premium)';

  @override
  String get drawRandom => 'Sortear (Aleatorio)';

  @override
  String get confirm => 'Confirmar';

  @override
  String get numberInput => 'Número';

  @override
  String get typeNumberHint => 'Escriba el número sorteado';

  @override
  String get errorInvalidNumber => 'El número debe estar entre 1 y 75';

  @override
  String get errorNumberDrawn => '¡El número ya fue sorteado!';

  @override
  String get paywallTitle => 'Recurso de Pago';

  @override
  String get paywallMessage =>
      'El Globo Automático es un recurso de pago. ¡Haz upgrade!';

  @override
  String get stopRoomTitle => 'Cerrar Sala';

  @override
  String get stopRoomMessage =>
      '¿Estás seguro de que quieres cerrar la sala? Todos los jugadores serán desconectados.';

  @override
  String get no => 'No';

  @override
  String get yes => 'Sí';

  @override
  String get hostRoomTitle => 'Sala de Bingo (Host)';

  @override
  String get playersInRoom => 'jugadores en la sala';

  @override
  String get shoutedBingo => 'gritó ¡BINGO!';

  @override
  String get cardId => 'ID de Cartón:';

  @override
  String get manualInputInstruction =>
      'Escribe el número sorteado en el globo físico';

  @override
  String get lobbySubtitle => 'Tu fiesta, tus reglas';

  @override
  String get lobbyWifiShowcase =>
      '¡El Bingo solo funciona localmente! Asegúrate de estar en la misma red Wi-Fi que tus invitados.';

  @override
  String get lobbyWifiBannerDefault => '¡Juega en la red Wi-Fi del anfitrión!';

  @override
  String lobbyWifiBannerConnected(String wifiName) {
    return 'Red actual: $wifiName\n¡Juega en la red del anfitrión!';
  }

  @override
  String get buttonWifi => 'WIFI';

  @override
  String get lobbyHostShowcase =>
      'Haz clic aquí si TÚ eres el anfitrión y quieres sacar las bolas de bingo.';

  @override
  String get lobbyJoinShowcase =>
      'Haz clic aquí para escanear el código QR y jugar usando un cartón en tu teléfono.';

  @override
  String get lobbySoloShowcase =>
      '¿Quieres probar jugar solo sin conexión? ¡Usa este modo!';

  @override
  String get soloButton => 'Bingo Individual';

  @override
  String get buttonConfig => 'CONFIG';

  @override
  String get scanWifiBannerDefault => 'Conéctate a la red Wi-Fi del anfitrión.';

  @override
  String scanWifiBannerConnected(String wifiName) {
    return 'Red: $wifiName\nConéctate a la red del anfitrión.';
  }

  @override
  String get scanManualButton => 'Ingresar Código Manualmente';

  @override
  String get revealNetwork => 'Revelar Red';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get termsOfUse => 'Condiciones de Uso';

  @override
  String get aboutDeveloper => 'Desarrollador (GitHub)';

  @override
  String get aboutTitle => 'Acerca de Bingo';

  @override
  String get aboutImportantTitle => '⚠️ Importante: Misma Red Wi-Fi';

  @override
  String get aboutImportantBody =>
      'El Bingo funciona a través de una conexión local segura. Para que los jugadores encuentren tu sala, TODOS (incluido el anfitrión) deben estar conectados a la misma red Wi-Fi.';

  @override
  String get aboutHowToPlayTitle => '📖 Cómo Jugar (Paso a Paso)';

  @override
  String get aboutStep1Title => 'Elige al Anfitrión';

  @override
  String get aboutStep1Desc =>
      'Una persona inicia el juego haciendo clic en \'Organizar un Bingo\' y comparte el Código de la Sala.';

  @override
  String get aboutStep2Title => 'Jugadores en la Sala';

  @override
  String get aboutStep2Desc =>
      'Los demás participantes hacen clic en \'Entrar\' e ingresan el código (o apuntan la cámara al Código QR).';

  @override
  String get aboutStep3Title => 'Marcando el Cartón';

  @override
  String get aboutStep3Desc =>
      'El anfitrión saca las bolas. Toca el número en el cartón de tu teléfono para marcarlo.';

  @override
  String get aboutStep4Title => '¡BINGO!';

  @override
  String get aboutStep4Desc =>
      '¿Completaste tu cartón? ¡Presiona el botón \'GRITAR BINGO\' antes que los demás para ganar!';

  @override
  String get aboutLanguage => '🌐 Idioma';

  @override
  String get scanEnterName => 'Ingresa tu nombre';

  @override
  String get scanJoin => 'Entrar';

  @override
  String get scanManualTitle => 'Ingresar Manualmente';

  @override
  String get scanManualHint => 'Pega el código o enlace de la sala abajo:';

  @override
  String get scanCancel => 'Cancelar';

  @override
  String get scanShowcaseScanner =>
      'Apunta tu cámara al Código QR del anfitrión para unirte rápidamente a la sala.';

  @override
  String get inviteRoomCode => 'Código de la Sala';

  @override
  String get inviteShareLink => 'Compartir Enlace de Invitación';

  @override
  String get inviteTitle => 'Invitar Jugadores';

  @override
  String get inviteScanDesc => '¡Escanea para unirte a la sala!';

  @override
  String inviteShareCodeMessage(String qrData) {
    return '¡Vamos a jugar Bingo! Nuestro código de sala es: $qrData';
  }

  @override
  String get inviteShareCodeTooltip => 'Compartir Código';

  @override
  String inviteShareLinkMessage(String qrData) {
    return '¡Ven a jugar Bingo! Solo haz clic desde tu teléfono: bingo://room/$qrData';
  }

  @override
  String inviteConnectedPlayers(int count) {
    return 'Jugadores Conectados: $count';
  }

  @override
  String get inviteWaitingPlayers => 'Esperando jugadores...';

  @override
  String get inviteStartBingo => '¡Iniciar Bingo!';

  @override
  String get lobbyPremiumTag => 'PREMIUM';

  @override
  String get lobbyUpgradeButton => 'Mejorar';

  @override
  String get playerGameTitle => 'Tu Cartón';

  @override
  String get playerGameShout => '¡Gritar BINGO!';

  @override
  String get playerScanNameHint => 'Ej: Mateo';

  @override
  String get playerScanTitle => 'Unirse a un Bingo';

  @override
  String get soloGameTitle => 'Bingo Individual';

  @override
  String get soloGameDraw => 'Sortear Número';

  @override
  String get hostSetupTitle => 'Organizar un Bingo';

  @override
  String get hostSetupRoomHint => 'Ej: Bingo del Tio Joe';

  @override
  String get hostSetupCreate => 'Crear Sala';

  @override
  String get hostSetupNameLabel => 'Nombra tu sala';

  @override
  String get hostSetupWifiWarning =>
      'Aviso: Todos los jugadores DEBEN estar conectados a la MISMA RED WI-FI para unirse a la sala.';

  @override
  String get hostSetupWifiDesc =>
      'Juega con personas en la misma red Wi-Fi. Ideal para fiestas y reuniones.';

  @override
  String get playerScanCameraHint =>
      'Apunta tu cámara al código QR del anfitrión';

  @override
  String get splashSubtitle => '¡La forma más divertida de jugar!';
}
