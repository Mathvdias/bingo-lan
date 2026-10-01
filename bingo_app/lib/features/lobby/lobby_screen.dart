import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/services/ad_service.dart';
import 'package:bingo_app/shared/services/revenue_config_service.dart';
import 'package:bingo_app/shared/services/subscription_service.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/banner_ad_widget.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:bingo_app/shared/ui/widgets/config_listenable_builder.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  /// O App Open é pré-carregado uma única vez por execução do app, na primeira
  /// montagem do lobby (que agora é a tela inicial, sem splash Flutter).
  static bool _appOpenPreloadRequested = false;

  final GlobalKey _hostKey = GlobalKey();
  final GlobalKey _joinKey = GlobalKey();
  final GlobalKey _soloKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (!_appOpenPreloadRequested) {
      _appOpenPreloadRequested = true;
      // O AdService exibe uma única vez quando carregar (nunca para premium
      // nem sobre o paywall).
      AdService.preloadAppOpenAd();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstLaunch();
    });
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isFirstTime = prefs.getBool('first_launch_showcase') ?? true;
    if (isFirstTime && mounted) {
      final keys = [_hostKey, _joinKey];
      if (RevenueConfigService.soloModeEnabled) keys.add(_soloKey);

      ShowcaseView.get().startShowCase(keys);
      await prefs.setBool('first_launch_showcase', false);
    }
  }

  /// Ações do tour: "Pular" encerra tudo, "Próximo" avança. Sem isso o tour
  /// só saía tocando passo a passo.
  List<TooltipActionButton> _tourActions(AppLocalizations l10n) {
    const labelStyle = TextStyle(
      color: AppColors.text,
      fontWeight: FontWeight.w700,
      fontSize: 13,
    );
    return [
      TooltipActionButton(
        type: TooltipDefaultActionType.skip,
        name: l10n.tourSkip,
        backgroundColor: AppColors.card,
        border: const Border.fromBorderSide(
          BorderSide(color: AppColors.outline, width: 2),
        ),
        textStyle: labelStyle,
      ),
      TooltipActionButton(
        type: TooltipDefaultActionType.next,
        name: l10n.tourNext,
        backgroundColor: AppColors.primary,
        border: const Border.fromBorderSide(
          BorderSide(color: AppColors.outline, width: 2),
        ),
        textStyle: labelStyle,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Reconstrói quando as flags mudam ao vivo (override em /debug/flags ou
    // novo fetch): botão de upgrade e modo solo dependem delas.
    return ConfigListenableBuilder(builder: _buildLobby);
  }

  Widget _buildLobby(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final tourActions = _tourActions(l10n);
    const tourActionConfig = TooltipActionConfig(
      alignment: MainAxisAlignment.end,
      actionGap: 8,
      gapBetweenContentAndAction: 12,
    );

    return Scaffold(
      key: const ValueKey<String>('lobby_screen'),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Ajuda: disco branco com contorno preto, no estilo do botão
          // "Upgrade" ao lado. Estático de propósito: um ícone animado no
          // canto da barra distrairia do herói.
          _HelpButton(
            key: const Key('lobby_help_button'),
            label: l10n.aboutTitle,
            onPressed: () => context.push('/about'),
          ),
          // Selo premium ou botão de upgrade, lendo o cache do status.
          if (RevenueConfigService.purchasesEnabled)
            ValueListenableBuilder<bool>(
              valueListenable: SubscriptionService.isPremium,
              builder: (context, isPremium, _) {
                if (isPremium) {
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    // Cores vêm do ChipThemeData: amarelo + texto preto.
                    child: Chip(
                      key: const Key('lobby_premium_chip'),
                      avatar: const Icon(Icons.workspace_premium),
                      label: Text(l10n.lobbyPremiumTag),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: _UpgradePill(
                    key: const Key('lobby_upgrade_button'),
                    label: l10n.lobbyUpgradeButton,
                    onPressed: () => context.push('/paywall?source=lobby'),
                  ),
                );
              },
            ),
        ],
      ),
      // Único lugar do app com banner. Ocupa zero altura quando não há anúncio.
      // Sem Center aqui: ele se expandiria até a altura máxima que o Scaffold
      // oferece à barra inferior e deixaria o corpo com altura zero.
      bottomNavigationBar: const SafeArea(top: false, child: BannerAdWidget()),
      body: Stack(
        children: [
          _LobbyBackground(),
          // Rolável: em 360x640 dp com banner e botão solo o conteúdo não
          // cabe inteiro, e com escala de texto grande menos ainda.
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Herói: bola 3D animada (toque inclina). Enquanto o
                    // bundle decodifica fica uma bola desenhada do mesmo
                    // tamanho, então nada pula.
                    const Center(
                      child: BingoLavaIconView(
                        key: Key('lobby_hero_ball'),
                        icon: BingoLavaIcon.ball,
                        size: 104,
                        interactive: true,
                        fallback: _BallFallback(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Semantics(
                      header: true,
                      child: Text(
                        'Bingo',
                        textAlign: TextAlign.center,
                        style: textTheme.displayLarge,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Semantics(
                      label: l10n.lobbySubtitle,
                      child: Text(
                        l10n.lobbySubtitle,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(
                          color: const Color.fromRGBO(18, 18, 18, 0.7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Showcase(
                      key: _hostKey,
                      description: l10n.lobbyHostShowcase,
                      tooltipActions: tourActions,
                      tooltipActionConfig: tourActionConfig,
                      child: Semantics(
                        label: l10n.startBingo,
                        button: true,
                        child: BingoButton(
                          key: const Key('lobby_btn_host'),
                          label: l10n.startBingo,
                          onPressed: () {
                            context.push('/host/setup');
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Showcase(
                      key: _joinKey,
                      description: l10n.lobbyJoinShowcase,
                      tooltipActions: tourActions,
                      tooltipActionConfig: tourActionConfig,
                      child: Semantics(
                        label: l10n.joinBingo,
                        button: true,
                        child: BingoButton(
                          key: const Key('lobby_btn_join'),
                          label: l10n.joinBingo,
                          onPressed: () {
                            context.push('/player/scan');
                          },
                          color: colorScheme.secondary,
                        ),
                      ),
                    ),
                    if (RevenueConfigService.soloModeEnabled) ...[
                      const SizedBox(height: 16),
                      Showcase(
                        key: _soloKey,
                        description: l10n.lobbySoloShowcase,
                        tooltipActions: tourActions,
                        tooltipActionConfig: tourActionConfig,
                        child: Semantics(
                          label: l10n.soloButton,
                          button: true,
                          child: BingoButton(
                            key: const Key('lobby_btn_solo'),
                            label: l10n.soloButton,
                            onPressed: () => context.push('/solo'),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bola azul com o 7 desenhada em Flutter: ocupa o lugar do herói Lava até o
/// bundle carregar (ou se ele faltar).
class _BallFallback extends StatelessWidget {
  const _BallFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.outline, width: 3),
        boxShadow: const [
          BoxShadow(color: AppColors.outline, offset: Offset(4, 4)),
        ],
      ),
      child: Container(
        width: 52,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.card,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.outline, width: 2),
        ),
        child: const Text(
          '7',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

/// Botão de ajuda: disco branco de 40 px com contorno preto de 2 px e o "?"
/// Material em preto, o mesmo desenho da pílula "Upgrade". Alvo de toque de
/// 48 px; [label] vai para o tooltip e para os leitores de tela.
class _HelpButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _HelpButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: 48,
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.outline, width: 2),
                ),
                child: const Icon(
                  Icons.help_outline,
                  color: AppColors.text,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botão "Upgrade": pílula branca com contorno preto, estrela amarela com
/// contorno e rótulo em âmbar escuro. Amarelo nunca vira texto sobre o creme.
/// A estrela segue Material: a 22 px a roseta Lava (textura de 180 px) viraria
/// um borrão amarelo e o ícone animado ao lado do rótulo distrairia do botão.
class _UpgradePill extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _UpgradePill({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: Material(
          color: AppColors.card,
          shape: const StadiumBorder(
            side: BorderSide(color: AppColors.outline, width: 2),
          ),
          child: InkWell(
            onTap: onPressed,
            customBorder: const StadiumBorder(),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 40),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 4, 14, 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.star, color: AppColors.primary, size: 22),
                        Icon(
                          Icons.star_outline,
                          color: AppColors.outline,
                          size: 22,
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.accentText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LobbyBackground extends StatefulWidget {
  @override
  State<_LobbyBackground> createState() => _LobbyBackgroundState();
}

class _LobbyBackgroundState extends State<_LobbyBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final value = _controller.value;
          return Stack(
            children: [
              Positioned(
                left: -50 + (value * 100),
                top: -50 + (value * 50),
                child: _buildBubble(
                  250,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                ),
              ),
              Positioned(
                right: -100 + (value * 150),
                bottom: 100 + (value * 100),
                child: _buildBubble(
                  350,
                  Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.1),
                ),
              ),
              Positioned(
                left: 100 + ((1 - value) * 100),
                bottom: -50 + ((1 - value) * 100),
                child: _buildBubble(
                  250,
                  AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 50,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}
