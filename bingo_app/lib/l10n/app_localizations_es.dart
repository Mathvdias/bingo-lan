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
}
