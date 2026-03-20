// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Bingo Lucca';

  @override
  String get startBingo => 'Organizar um Bingo';

  @override
  String get joinBingo => 'Entrar em um Bingo';

  @override
  String get upgrade => 'Melhorar Conta';

  @override
  String get premiumBadge => 'PREMIUM';

  @override
  String get manualGlobe => 'Manual (Físico)';

  @override
  String get virtualGlobe => 'Virtual';

  @override
  String get autoGlobe => 'Globo Automático (Premium)';

  @override
  String get drawRandom => 'Sortear (Aleatório)';

  @override
  String get confirm => 'Confirmar';

  @override
  String get numberInput => 'Número';

  @override
  String get typeNumberHint => 'Digite o número sorteado';

  @override
  String get errorInvalidNumber => 'Número deve ser entre 1 e 75';

  @override
  String get errorNumberDrawn => 'Número já foi sorteado!';

  @override
  String get paywallTitle => 'Recurso Pago';

  @override
  String get paywallMessage =>
      'O Globo Automático é um recurso pago. Faça upgrade!';

  @override
  String get stopRoomTitle => 'Encerrar Sala';

  @override
  String get stopRoomMessage =>
      'Você tem certeza que deseja encerrar a sala? Todos os jogadores serão desconectados.';

  @override
  String get no => 'Não';

  @override
  String get yes => 'Sim';

  @override
  String get hostRoomTitle => 'Sala do Bingo (Host)';

  @override
  String get playersInRoom => 'jogadores na sala';

  @override
  String get shoutedBingo => 'gritou BINGO!';

  @override
  String get cardId => 'Cartela ID:';

  @override
  String get manualInputInstruction =>
      'Digite o número sorteado no globo físico';

  @override
  String get lobbySubtitle => 'Sua festa, suas regras';

  @override
  String get lobbyWifiShowcase =>
      'O Bingo funciona apenas localmente! Certifique-se de estar na mesma rede Wi-Fi que seus convidados.';

  @override
  String get lobbyWifiBannerDefault =>
      'Jogue na mesma rede Wi-Fi do anfitrião!';

  @override
  String lobbyWifiBannerConnected(String wifiName) {
    return 'Rede atual: $wifiName\nJogue na mesma rede do anfitrião!';
  }

  @override
  String get buttonWifi => 'WIFI';

  @override
  String get lobbyHostShowcase =>
      'Clique aqui se VOCÊ for o organizador e quiser sortear as bolas do bingo.';

  @override
  String get lobbyJoinShowcase =>
      'Clique aqui para scanear o QR Code e jogar usando uma cartela no seu celular.';

  @override
  String get lobbySoloShowcase =>
      'Quer testar jogar offline sozinho? Use este modo!';

  @override
  String get soloButton => 'Bingo Individual';

  @override
  String get buttonConfig => 'CONFIG';

  @override
  String get scanWifiBannerDefault =>
      'Conecte-se à mesma rede Wi-Fi do anfitrião.';

  @override
  String scanWifiBannerConnected(String wifiName) {
    return 'Rede: $wifiName\nConecte-se na rede do anfitrião.';
  }

  @override
  String get scanManualButton => 'Digitar Código Manualmente';

  @override
  String get revealNetwork => 'Revelar Rede';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get termsOfUse => 'Termos de Uso';
}
