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

  @override
  String get aboutDeveloper => 'Desenvolvedor (GitHub)';

  @override
  String get aboutTitle => 'Sobre o Bingo';

  @override
  String get aboutImportantTitle => '⚠️ Importante: Mesma Rede Wi-Fi';

  @override
  String get aboutImportantBody =>
      'O Bingo funciona através de uma conexão local segura. Para que os jogadores encontrem a sua sala, TODOS (inclusive o organizador) devem estar conectados à mesma rede Wi-Fi.';

  @override
  String get aboutHowToPlayTitle => '📖 Como Jogar (Passo a Passo)';

  @override
  String get aboutStep1Title => 'Escolha o Organizador';

  @override
  String get aboutStep1Desc =>
      'Uma pessoa inicia a partida clicando em \'Organizar um Bingo\' e compartilha o Código da Sala.';

  @override
  String get aboutStep2Title => 'Jogadores na Sala';

  @override
  String get aboutStep2Desc =>
      'Os demais participantes clicam em \'Entrar\' e digitam o código (ou apontam a câmera pro QR Code).';

  @override
  String get aboutStep3Title => 'Marcando a Cartela';

  @override
  String get aboutStep3Desc =>
      'O organizador sorteia as bolas. Toque no número da sua cartela no celular para marcá-lo.';

  @override
  String get aboutStep4Title => 'BINGO!';

  @override
  String get aboutStep4Desc =>
      'Completou a cartela? Aperte o botão \'GRITAR BINGO\' antes de todo mundo para vencer!';

  @override
  String get aboutLanguage => '🌐 Idioma / Language';

  @override
  String get scanEnterName => 'Digite seu nome';

  @override
  String get scanJoin => 'Entrar';

  @override
  String get scanManualTitle => 'Entrar Manualmente';

  @override
  String get scanManualHint => 'Cole o código ou link da sala abaixo:';

  @override
  String get scanCancel => 'Cancelar';

  @override
  String get scanShowcaseScanner =>
      'Aponte a câmera para o QR Code do anfitrião para entrar na sala rapidamente.';

  @override
  String get inviteRoomCode => 'Código da Sala';

  @override
  String get inviteShareLink => 'Compartilhar Link de Convite';

  @override
  String get inviteTitle => 'Convide os Jogadores';

  @override
  String get inviteScanDesc => 'Escaneie para entrar na sala!';

  @override
  String inviteShareCodeMessage(String qrData) {
    return 'Bora pro Bingo da Galera! Nosso código da sala é: $qrData';
  }

  @override
  String get inviteShareCodeTooltip => 'Compartilhar Código';

  @override
  String inviteShareLinkMessage(String qrData) {
    return 'Vem pro Bingo da Galera! Só clicar pelo celular: bingo://room/$qrData';
  }

  @override
  String inviteConnectedPlayers(int count) {
    return 'Jogadores Conectados: $count';
  }

  @override
  String get inviteWaitingPlayers => 'Aguardando jogadores...';

  @override
  String get inviteStartBingo => 'Iniciar Bingo!';

  @override
  String get lobbyPremiumTag => 'PREMIUM';

  @override
  String get lobbyUpgradeButton => 'Upgrade';

  @override
  String get playerGameTitle => 'Sua Cartela';

  @override
  String get playerGameShout => 'Gritar BINGO!';

  @override
  String get playerScanNameHint => 'Ex: Matheus';

  @override
  String get playerScanTitle => 'Entrar em um Bingo';

  @override
  String get soloGameTitle => 'Bingo Individual';

  @override
  String get soloGameDraw => 'Sortear Número';

  @override
  String get hostSetupTitle => 'Organizar um Bingo';

  @override
  String get hostSetupRoomHint => 'Ex: Bingo do Tio Zé';

  @override
  String get hostSetupCreate => 'Criar Sala';

  @override
  String get hostSetupNameLabel => 'Dê um nome para a sala';

  @override
  String get hostSetupWifiWarning =>
      'Aviso: Todos os jogadores DEVEM estar conectados à MESMA REDE WI-FI para conseguir entrar na sala.';

  @override
  String get hostSetupWifiDesc =>
      'Jogue com pessoas na mesma rede Wi-Fi. Ideal para festas e encontros.';

  @override
  String get playerScanCameraHint => 'Aponte a câmera para o QR Code do Host';

  @override
  String get splashSubtitle => 'O jeito mais divertido de jogar!';
}
