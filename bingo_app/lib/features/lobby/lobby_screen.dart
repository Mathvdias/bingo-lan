import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/services/revenue_config_service.dart';
import 'package:bingo_app/shared/services/subscription_service.dart';
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
                    child: Chip(
                      key: const Key('lobby_premium_chip'),
                      label: Text(l10n.lobbyPremiumTag),
                      backgroundColor: Colors.amber,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                }

                return TextButton.icon(
                  key: const Key('lobby_upgrade_button'),
                  onPressed: () => context.push('/paywall?source=lobby'),
                  icon: const Icon(Icons.star, color: Colors.amber),
                  label: Text(l10n.lobbyUpgradeButton),
                  style: TextButton.styleFrom(foregroundColor: Colors.amber),
                );
              },
            ),
        ],
      ),
      // Único lugar do app com banner. Ocupa zero altura quando não há anúncio.
      bottomNavigationBar: const SafeArea(
        top: false,
        child: Center(child: BannerAdWidget()),
      ),
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
                child: _buildBubble(250, Colors.amber.withValues(alpha: 0.1)),
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
