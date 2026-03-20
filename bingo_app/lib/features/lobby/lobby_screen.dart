import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/services/revenue_config_service.dart';
import 'package:bingo_app/shared/services/subscription_service.dart';
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
  bool _isPremium = false;
  bool _checkingSubscription = true;

  final GlobalKey _hostKey = GlobalKey();
  final GlobalKey _joinKey = GlobalKey();
  final GlobalKey _soloKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _checkSubscription();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstLaunch();
    });
  }

  @override
  void dispose() {
    super.dispose();
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

  Future<void> _checkSubscription() async {
    setState(() => _checkingSubscription = true);
    try {
      final hasSub = await SubscriptionService.checkSubscriptionStatus();
      if (mounted) {
        setState(() {
          _isPremium = hasSub;
          _checkingSubscription = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _checkingSubscription = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => context.push('/about'),
          ),
          // Premium badge or upgrade button
          if (RevenueConfigService.purchasesEnabled)
            StreamBuilder<bool>(
              stream: SubscriptionService.premiumStatusStream,
              initialData: _isPremium,
              builder: (context, snapshot) {
                final isPremium = snapshot.data ?? false;
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !_isPremium &&
                    _checkingSubscription) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                if (isPremium) {
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Chip(
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
                  onPressed: () => context.push('/paywall'),
                  icon: const Icon(Icons.star, color: Colors.amber),
                  label: Text(l10n.lobbyUpgradeButton),
                  style: TextButton.styleFrom(foregroundColor: Colors.amber),
                );
              },
            ),
        ],
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
                Text(
                  'Bingo',
                  textAlign: TextAlign.center,
                  style: textTheme.displayLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.lobbySubtitle,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: const Color.fromRGBO(18, 18, 18, 0.7),
                  ),
                ),
                const SizedBox(height: 64),
                Showcase(
                  key: _hostKey,
                  description: l10n.lobbyHostShowcase,
                  child: BingoButton(
                    label: l10n.startBingo,
                    onPressed: () {
                      context.push('/host/setup');
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Showcase(
                  key: _joinKey,
                  description: l10n.lobbyJoinShowcase,
                  child: BingoButton(
                    label: l10n.joinBingo,
                    onPressed: () {
                      context.push('/player/scan');
                    },
                    color: colorScheme.secondary,
                  ),
                ),
                if (RevenueConfigService.soloModeEnabled) ...[
                  const SizedBox(height: 16),
                  Showcase(
                    key: _soloKey,
                    description: l10n.lobbySoloShowcase,
                    child: BingoButton(
                      label: l10n.soloButton,
                      onPressed: () => context.push('/solo'),
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
        duration: const Duration(seconds: 20), vsync: this)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        return Stack(
          children: [
            Positioned(
              left: -50 + (value * 100),
              top: -50 + (value * 50),
              child: _buildBubble(250, Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)),
            ),
            Positioned(
              right: -100 + (value * 150),
              bottom: 100 + (value * 100),
              child: _buildBubble(350, Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1)),
            ),
            Positioned(
              left: 100 + ((1 - value) * 100),
              bottom: -50 + ((1 - value) * 100),
              child: _buildBubble(250, Colors.amber.withValues(alpha: 0.1)),
            ),
          ],
        );
      },
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
          )
        ],
      ),
    );
  }
}
