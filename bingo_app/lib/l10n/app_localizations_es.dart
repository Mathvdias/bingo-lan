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
}
