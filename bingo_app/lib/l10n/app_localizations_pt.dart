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
  String get manualGlobe => 'Manual';

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
  String playersInRoom(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jogadores na sala',
      one: '1 jogador na sala',
      zero: 'Nenhum jogador na sala',
    );
    return '$_temp0';
  }

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
  String get scanWifiBannerNoWifi =>
      'Você não está no Wi-Fi. Conecte-se à rede do anfitrião.';

  @override
  String scanWifiBannerOnWifi(String ip) {
    return 'Wi-Fi conectado ($ip). Use a mesma rede do anfitrião.';
  }

  @override
  String get scanManualButton => 'Digitar código';

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
  String get aboutImportantTitle => 'Importante: Mesma Rede Wi-Fi';

  @override
  String get aboutImportantBody =>
      'O Bingo funciona através de uma conexão local segura. Para que os jogadores encontrem a sua sala, TODOS (inclusive o organizador) devem estar conectados à mesma rede Wi-Fi.';

  @override
  String get aboutHowToPlayTitle => 'Como Jogar (Passo a Passo)';

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
  String get aboutLanguage => 'Idioma / Language';

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
  String get inviteTitle => 'Convide os Jogadores';

  @override
  String get inviteScanDesc => 'Escaneie para entrar na sala!';

  @override
  String inviteShareLinkMessage(String qrData) {
    return 'Vem pro Bingo! Só tocar no link pelo celular:\n$qrData';
  }

  @override
  String inviteConnectedPlayers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jogadores conectados',
      one: '1 jogador conectado',
      zero: 'Nenhum jogador conectado ainda',
    );
    return '$_temp0';
  }

  @override
  String get inviteWaitingPlayers => 'Aguardando jogadores...';

  @override
  String get inviteStartBingo => 'Iniciar Bingo!';

  @override
  String get lobbyPremiumTag => 'PREMIUM';

  @override
  String get lobbyUpgradeButton => 'Premium';

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
  String get paywallHeroTitle => 'Seja Premium';

  @override
  String get paywallHeroSubtitle =>
      'Festas maiores, sem limites e sem interrupções.';

  @override
  String get paywallBenefitUnlimitedPlayers => 'Jogadores ilimitados por sala';

  @override
  String get paywallBenefitAutoGlobe =>
      'Globo automático: o app sorteia as bolas por você';

  @override
  String get paywallBenefitNoAds => 'Sem anúncios';

  @override
  String get paywallPeriodWeekly => 'Semanal';

  @override
  String get paywallPeriodMonthly => 'Mensal';

  @override
  String get paywallPeriodTwoMonth => 'Bimestral';

  @override
  String get paywallPeriodThreeMonth => 'Trimestral';

  @override
  String get paywallPeriodSixMonth => 'Semestral';

  @override
  String get paywallPeriodAnnual => 'Anual';

  @override
  String get paywallPeriodLifetime => 'Vitalício';

  @override
  String get paywallPeriodCustom => 'Plano';

  @override
  String get paywallBilledWeekly => 'Cobrado toda semana';

  @override
  String get paywallBilledMonthly => 'Cobrado todo mês';

  @override
  String get paywallBilledTwoMonth => 'Cobrado a cada 2 meses';

  @override
  String get paywallBilledThreeMonth => 'Cobrado a cada 3 meses';

  @override
  String get paywallBilledSixMonth => 'Cobrado a cada 6 meses';

  @override
  String get paywallBilledAnnual => 'Cobrado uma vez por ano';

  @override
  String get paywallBilledCustom => 'Assinatura';

  @override
  String get paywallOneTimePayment => 'Pagamento único';

  @override
  String paywallSavings(int percent) {
    return 'Economize $percent%';
  }

  @override
  String paywallCta(String price) {
    return 'Continuar por $price';
  }

  @override
  String get paywallRestore => 'Restaurar compras';

  @override
  String get paywallLegal =>
      'As assinaturas renovam automaticamente, salvo cancelamento com pelo menos 24 horas de antecedência do fim do período atual. Cancele quando quiser nas configurações da sua conta na loja.';

  @override
  String get paywallEmpty => 'Nenhum plano disponível no momento.';

  @override
  String get paywallRetry => 'Tentar de novo';

  @override
  String get paywallErrorLoad =>
      'Não foi possível carregar os planos. Verifique sua conexão e tente de novo.';

  @override
  String get paywallErrorPurchase =>
      'Não foi possível concluir a compra. Tente de novo.';

  @override
  String get paywallErrorRestore =>
      'Não foi possível restaurar suas compras. Tente de novo.';

  @override
  String get paywallRestoreNothing =>
      'Nenhuma compra anterior encontrada para esta conta.';

  @override
  String get paywallRestoreSuccess =>
      'Compras restauradas. Bem-vindo ao Premium!';

  @override
  String get paywallClose => 'Fechar';

  @override
  String playersCapacity(int count, int max) {
    return '$count/$max jogadores (plano grátis)';
  }

  @override
  String get routeErrorMessage => 'Não foi possível abrir esta tela.';

  @override
  String get cardFree => 'LIVRE';

  @override
  String get inviteDefaultRoomName => 'Sala de Bingo';

  @override
  String get hostSetupErrorEmptyName => 'O nome da sala não pode ficar vazio.';

  @override
  String get hostSetupErrorNoWifi =>
      'Não foi possível obter o endereço do Wi-Fi. Verifique sua conexão Wi-Fi.';

  @override
  String get hostSetupErrorPortUnavailable =>
      'Nenhuma porta de rede disponível para criar a sala. Feche outros apps que usam a rede e tente de novo.';

  @override
  String get hostSetupErrorUnexpected =>
      'Algo deu errado ao criar a sala. Tente de novo.';

  @override
  String get hostRoomErrorConnection =>
      'Houve um problema de conexão com um jogador.';

  @override
  String get hostRoomWinnerTitle => 'BINGO!';

  @override
  String hostRoomWinnerMessage(String name) {
    return '$name venceu esta rodada!';
  }

  @override
  String get hostRoomNewRound => 'Nova rodada';

  @override
  String get hostRoomEndRoom => 'Encerrar sala';

  @override
  String get hostRoomWaitingDraw =>
      'Sorteie o primeiro número para começar a rodada.';

  @override
  String get hostRoomRoundOverHint =>
      'Rodada encerrada. Comece uma nova rodada ou encerre a sala.';

  @override
  String drawnCount(int count) {
    return '$count/75 sorteados';
  }

  @override
  String get scanErrorInvalidCode =>
      'Código inválido. Peça um novo QR Code ao anfitrião.';

  @override
  String get scanErrorRejected =>
      'O anfitrião não aceitou a conexão. Confira a rede Wi-Fi e o código da sala.';

  @override
  String get scanErrorTimeout =>
      'O anfitrião não respondeu. Confira se você está na mesma rede Wi-Fi.';

  @override
  String get scanErrorUnexpected => 'Erro inesperado ao entrar na sala.';

  @override
  String get scanErrorNotOnWifi =>
      'Você não está no Wi-Fi. Conecte-se à mesma rede do anfitrião e tente de novo.';

  @override
  String scanErrorDifferentNetwork(String playerIp, String hostIp) {
    return 'Você parece estar em outra rede (seu IP $playerIp, anfitrião $hostIp). Entre na mesma rede Wi-Fi do anfitrião.';
  }

  @override
  String get scanErrorHostUnreachable =>
      'Não consegui falar com o anfitrião. Confira se estão na mesma rede Wi-Fi. Redes de convidados, hotel ou condomínio costumam bloquear; nesse caso use o hotspot do anfitrião.';

  @override
  String get scanErrorRoomClosed =>
      'A sala não está mais aberta. Peça um novo convite ao anfitrião.';

  @override
  String get playerGameLastCalled => 'Última bola';

  @override
  String get playerGameNoCallsYet => 'Nenhum número sorteado ainda';

  @override
  String get connectionConnecting => 'Conectando ao anfitrião...';

  @override
  String get connectionReconnecting => 'Conexão perdida. Reconectando...';

  @override
  String get connectionDisconnected => 'Desconectado do anfitrião.';

  @override
  String get connectionRetry => 'Tentar de novo';

  @override
  String get playerGameYouWon => 'BINGO! Você venceu!';

  @override
  String playerGameSomeoneWon(String name) {
    return '$name venceu esta rodada.';
  }

  @override
  String get playerGameWaitNextRound =>
      'Aguarde o anfitrião começar uma nova rodada ou volte ao início.';

  @override
  String get backToLobby => 'Voltar ao início';

  @override
  String get playerGameClaimRejected =>
      'Ainda não é bingo! Confira sua cartela e continue jogando.';

  @override
  String get playerGameRoomClosedTitle => 'O anfitrião encerrou a sala';

  @override
  String get playerGameRoomClosedMessage =>
      'Este jogo acabou. Obrigado por jogar!';

  @override
  String get playerGameLeaveTitle => 'Sair do jogo?';

  @override
  String get playerGameLeaveMessage =>
      'Você vai perder sua cartela e sair da sala.';

  @override
  String get playerGameLeave => 'Sair';

  @override
  String get playerGameStay => 'Ficar';

  @override
  String playerGameShoutCooldown(int seconds) {
    return 'Aguarde ${seconds}s';
  }

  @override
  String get inviteShareInvite => 'Compartilhar convite';

  @override
  String get inviteCopyLink => 'Copiar link';

  @override
  String get inviteLinkCopied => 'Link copiado!';

  @override
  String invitePasteHint(String button) {
    return 'ou peça para colar o link no botão \'$button\'';
  }

  @override
  String get playersCapacityLabel => 'jogadores (plano grátis)';

  @override
  String get playersConnectedLabel => 'jogadores conectados';

  @override
  String get hostRoomUndoLast => 'Desfazer última bola';

  @override
  String hostRoomUndone(String label) {
    return 'Bola $label desfeita';
  }

  @override
  String get hostRoomPause => 'Pausar';

  @override
  String get hostRoomResume => 'Retomar';

  @override
  String get hostRoomEmptyTitle => 'Nenhuma bola ainda';

  @override
  String get tourSkip => 'Pular';

  @override
  String get tourNext => 'Próximo';

  @override
  String get cardCellMarked => 'marcado';

  @override
  String get cardCellCalled => 'sorteado, não marcado';

  @override
  String get cardCellNotCalled => 'não sorteado';

  @override
  String get cardCellFreeSpace => 'espaço livre';

  @override
  String get scanCameraDeniedTitle => 'Sem acesso à câmera';

  @override
  String get scanCameraDeniedMessage =>
      'Permita o uso da câmera nas configurações para ler o QR Code, ou digite o código manualmente.';

  @override
  String get scanCameraErrorMessage =>
      'Não foi possível abrir a câmera. Tente de novo ou digite o código manualmente.';

  @override
  String get scanOpenSettings => 'Abrir configurações';
}
