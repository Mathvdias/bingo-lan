import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/services/revenue_config_service.dart';
import 'package:bingo_app/shared/services/subscription_service.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/banner_ad_widget.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
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
  final GlobalKey _hostKey = GlobalKey();
  final GlobalKey _joinKey = GlobalKey();
  final GlobalKey _soloKey = GlobalKey();

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      key: const ValueKey<String>('lobby_screen'),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
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
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                    const SizedBox(height: 64),
                    Showcase(
                      key: _hostKey,
                      description: l10n.lobbyHostShowcase,
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

/// Botão "Upgrade": pílula branca com contorno preto, estrela amarela com
/// contorno e rótulo em âmbar escuro. Amarelo nunca vira texto sobre o creme.
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
