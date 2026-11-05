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
  String get manualGlobe => 'Manual';

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
  String playersInRoom(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jugadores en la sala',
      one: '1 jugador en la sala',
      zero: 'Ningún jugador en la sala',
    );
    return '$_temp0';
  }

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
  String get scanWifiBannerNoWifi =>
      'No estás en Wi-Fi. Conéctate a la red del anfitrión.';

  @override
  String scanWifiBannerOnWifi(String ip) {
    return 'Wi-Fi conectado ($ip). Usa la misma red que el anfitrión.';
  }

  @override
  String get scanManualButton => 'Ingresar código';

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
  String get aboutImportantTitle => 'Importante: Misma Red Wi-Fi';

  @override
  String get aboutImportantBody =>
      'El Bingo funciona a través de una conexión local segura. Para que los jugadores encuentren tu sala, TODOS (incluido el anfitrión) deben estar conectados a la misma red Wi-Fi.';

  @override
  String get aboutHowToPlayTitle => 'Cómo Jugar (Paso a Paso)';

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
  String get aboutLanguage => 'Idioma';

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
  String get inviteTitle => 'Invitar Jugadores';

  @override
  String get inviteScanDesc => '¡Escanea para unirte a la sala!';

  @override
  String inviteShareLinkMessage(String qrData) {
    return '¡Ven a jugar Bingo! Solo toca el enlace desde tu celular:\n$qrData';
  }

  @override
  String inviteConnectedPlayers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jugadores conectados',
      one: '1 jugador conectado',
      zero: 'Ningún jugador conectado todavía',
    );
    return '$_temp0';
  }

  @override
  String get inviteWaitingPlayers => 'Esperando jugadores...';

  @override
  String get inviteStartBingo => '¡Iniciar Bingo!';

  @override
  String get lobbyPremiumTag => 'PREMIUM';

  @override
  String get lobbyUpgradeButton => 'Premium';

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
  String get paywallHeroTitle => 'Hazte Premium';

  @override
  String get paywallHeroSubtitle =>
      'Fiestas más grandes, sin límites y sin interrupciones.';

  @override
  String get paywallBenefitUnlimitedPlayers => 'Jugadores ilimitados por sala';

  @override
  String get paywallBenefitAutoGlobe =>
      'Globo automático: la app sortea las bolas por ti';

  @override
  String get paywallBenefitNoAds => 'Sin anuncios';

  @override
  String get paywallPeriodWeekly => 'Semanal';

  @override
  String get paywallPeriodMonthly => 'Mensual';

  @override
  String get paywallPeriodTwoMonth => 'Bimestral';

  @override
  String get paywallPeriodThreeMonth => 'Trimestral';

  @override
  String get paywallPeriodSixMonth => 'Semestral';

  @override
  String get paywallPeriodAnnual => 'Anual';

  @override
  String get paywallPeriodLifetime => 'De por vida';

  @override
  String get paywallPeriodCustom => 'Plan';

  @override
  String get paywallBilledWeekly => 'Se cobra cada semana';

  @override
  String get paywallBilledMonthly => 'Se cobra cada mes';

  @override
  String get paywallBilledTwoMonth => 'Se cobra cada 2 meses';

  @override
  String get paywallBilledThreeMonth => 'Se cobra cada 3 meses';

  @override
  String get paywallBilledSixMonth => 'Se cobra cada 6 meses';

  @override
  String get paywallBilledAnnual => 'Se cobra una vez al año';

  @override
  String get paywallBilledCustom => 'Suscripción';

  @override
  String get paywallOneTimePayment => 'Pago único';

  @override
  String paywallSavings(int percent) {
    return 'Ahorra $percent%';
  }

  @override
  String paywallCta(String price) {
    return 'Continuar por $price';
  }

  @override
  String get paywallRestore => 'Restaurar compras';

  @override
  String get paywallLegal =>
      'Las suscripciones se renuevan automáticamente salvo que se cancelen al menos 24 horas antes del final del período actual. Cancela cuando quieras en la configuración de tu cuenta de la tienda.';

  @override
  String get paywallEmpty => 'No hay planes disponibles por ahora.';

  @override
  String get paywallRetry => 'Reintentar';

  @override
  String get paywallErrorLoad =>
      'No se pudieron cargar los planes. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get paywallErrorPurchase =>
      'No se pudo completar la compra. Inténtalo de nuevo.';

  @override
  String get paywallErrorRestore =>
      'No se pudieron restaurar tus compras. Inténtalo de nuevo.';

  @override
  String get paywallRestoreNothing =>
      'No se encontraron compras anteriores para esta cuenta.';

  @override
  String get paywallRestoreSuccess =>
      'Compras restauradas. ¡Bienvenido a Premium!';

  @override
  String get paywallClose => 'Cerrar';

  @override
  String playersCapacity(int count, int max) {
    return '$count/$max jugadores (plan gratis)';
  }

  @override
  String get routeErrorMessage => 'No se pudo abrir esta pantalla.';

  @override
  String get cardFree => 'LIBRE';

  @override
  String get inviteDefaultRoomName => 'Sala de Bingo';

  @override
  String get hostSetupErrorEmptyName =>
      'El nombre de la sala no puede estar vacío.';

  @override
  String get hostSetupErrorNoWifi =>
      'No se pudo obtener la dirección Wi-Fi. Revisa tu conexión Wi-Fi.';

  @override
  String get hostSetupErrorPortUnavailable =>
      'No hay ningún puerto de red disponible para crear la sala. Cierra otras apps que usen la red e inténtalo de nuevo.';

  @override
  String get hostSetupErrorUnexpected =>
      'Algo salió mal al crear la sala. Inténtalo de nuevo.';

  @override
  String get hostRoomErrorConnection =>
      'Hubo un problema de conexión con un jugador.';

  @override
  String get hostRoomWinnerTitle => '¡BINGO!';

  @override
  String hostRoomWinnerMessage(String name) {
    return '¡$name ganó esta ronda!';
  }

  @override
  String get hostRoomNewRound => 'Nueva ronda';

  @override
  String get hostRoomEndRoom => 'Cerrar sala';

  @override
  String get hostRoomWaitingDraw =>
      'Sortea el primer número para empezar la ronda.';

  @override
  String get hostRoomRoundOverHint =>
      'Ronda terminada. Empieza una nueva ronda o cierra la sala.';

  @override
  String drawnCount(int count) {
    return '$count/75 sorteados';
  }

  @override
  String get scanErrorInvalidCode =>
      'Código inválido. Pide un nuevo código QR al anfitrión.';

  @override
  String get scanErrorRejected =>
      'El anfitrión no aceptó la conexión. Revisa la red Wi-Fi y el código de la sala.';

  @override
  String get scanErrorTimeout =>
      'El anfitrión no respondió. Asegúrate de estar en la misma red Wi-Fi.';

  @override
  String get scanErrorUnexpected => 'Error inesperado al entrar a la sala.';

  @override
  String get scanErrorNotOnWifi =>
      'No estás en Wi-Fi. Conéctate a la misma red del anfitrión e inténtalo de nuevo.';

  @override
  String scanErrorDifferentNetwork(String playerIp, String hostIp) {
    return 'Parece que estás en otra red (tu IP $playerIp, anfitrión $hostIp). Entra a la misma red Wi-Fi del anfitrión.';
  }

  @override
  String get scanErrorHostUnreachable =>
      'No pude comunicarme con el anfitrión. Verifica que estén en la misma red Wi-Fi. Las redes de invitados, de hotel o de edificio suelen bloquear la conexión entre dispositivos; en ese caso usa el hotspot del anfitrión.';

  @override
  String get scanErrorRoomClosed =>
      'La sala ya no está abierta. Pide una nueva invitación al anfitrión.';

  @override
  String get playerGameLastCalled => 'Última bola';

  @override
  String get playerGameNoCallsYet => 'Aún no hay números sorteados';

  @override
  String get connectionConnecting => 'Conectando con el anfitrión...';

  @override
  String get connectionReconnecting => 'Conexión perdida. Reconectando...';

  @override
  String get connectionDisconnected => 'Desconectado del anfitrión.';

  @override
  String get connectionRetry => 'Reintentar';

  @override
  String get playerGameYouWon => '¡BINGO! ¡Ganaste!';

  @override
  String playerGameSomeoneWon(String name) {
    return '$name ganó esta ronda.';
  }

  @override
  String get playerGameWaitNextRound =>
      'Espera a que el anfitrión empiece una nueva ronda o vuelve al inicio.';

  @override
  String get backToLobby => 'Volver al inicio';

  @override
  String get playerGameClaimRejected =>
      '¡Todavía no es bingo! Revisa tu cartón y sigue jugando.';

  @override
  String get playerGameRoomClosedTitle => 'El anfitrión cerró la sala';

  @override
  String get playerGameRoomClosedMessage =>
      'Este juego terminó. ¡Gracias por jugar!';

  @override
  String get playerGameLeaveTitle => '¿Salir del juego?';

  @override
  String get playerGameLeaveMessage =>
      'Perderás tu cartón y saldrás de la sala.';

  @override
  String get playerGameLeave => 'Salir';

  @override
  String get playerGameStay => 'Quedarme';

  @override
  String playerGameShoutCooldown(int seconds) {
    return 'Espera ${seconds}s';
  }

  @override
  String get inviteShareInvite => 'Compartir invitación';

  @override
  String get inviteCopyLink => 'Copiar enlace';

  @override
  String get inviteLinkCopied => '¡Enlace copiado!';

  @override
  String invitePasteHint(String button) {
    return 'o pide que peguen el enlace en \'$button\'';
  }

  @override
  String get playersCapacityLabel => 'jugadores (plan gratis)';

  @override
  String get playersConnectedLabel => 'jugadores conectados';

  @override
  String get hostRoomUndoLast => 'Deshacer última bola';

  @override
  String hostRoomUndone(String label) {
    return 'Bola $label deshecha';
  }

  @override
  String get hostRoomPause => 'Pausar';

  @override
  String get hostRoomResume => 'Reanudar';

  @override
  String get hostRoomEmptyTitle => 'Aún sin bolas';

  @override
  String get tourSkip => 'Omitir';

  @override
  String get tourNext => 'Siguiente';

  @override
  String get cardCellMarked => 'marcado';

  @override
  String get cardCellCalled => 'cantado, sin marcar';

  @override
  String get cardCellNotCalled => 'no cantado';

  @override
  String get cardCellFreeSpace => 'espacio libre';

  @override
  String get scanCameraDeniedTitle => 'Sin acceso a la cámara';

  @override
  String get scanCameraDeniedMessage =>
      'Permite el acceso a la cámara en Ajustes para leer el código QR, o ingresa el código manualmente.';

  @override
  String get scanCameraErrorMessage =>
      'No se pudo abrir la cámara. Inténtalo de nuevo o ingresa el código manualmente.';

  @override
  String get scanOpenSettings => 'Abrir ajustes';

  @override
  String get lobbySettingsButton => 'Ajustes';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSoundSection => 'Sonido';

  @override
  String get settingsSoundEffects => 'Efectos de sonido';

  @override
  String get settingsSoundEffectsSubtitle => 'Sonidos al sortear, marcar y ganar';

  @override
  String get settingsVolume => 'Volumen';

  @override
  String get settingsVolumeTest => 'Probar';

  @override
  String get settingsCreditsSection => 'Créditos';

  @override
  String get settingsAudioCredits => 'Efectos de sonido creados para esta app, sin licencias de terceros.';
}
