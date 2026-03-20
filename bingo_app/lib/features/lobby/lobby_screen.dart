import 'package:app_settings/app_settings.dart';
import 'package:bingo_app/shared/services/revenue_config_service.dart';
import 'package:bingo_app/shared/services/subscription_service.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart' show AppColors;
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bingo_app/l10n/app_localizations.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  bool _isPremium = false;
  bool _checkingSubscription = true;

  final GlobalKey _wifiKey = GlobalKey();
  final GlobalKey _hostKey = GlobalKey();
  final GlobalKey _joinKey = GlobalKey();
  final GlobalKey _soloKey = GlobalKey();

  String? _wifiName;

  @override
  void initState() {
    super.initState();
    ShowcaseView.register();
    _checkSubscription();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstLaunch();
    });
  }

  @override
  void dispose() {
    ShowcaseView.get().unregister();
    super.dispose();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isFirstTime = prefs.getBool('first_launch_showcase') ?? true;
    if (isFirstTime && mounted) {
      final keys = [_wifiKey, _hostKey, _joinKey];
      if (RevenueConfigService.soloModeEnabled) keys.add(_soloKey);

      ShowcaseView.get().startShowCase(keys);
      await prefs.setBool('first_launch_showcase', false);
    }
  }

  Future<void> _fetchWifiName() async {
    try {
      final status = await Permission.locationWhenInUse.request();
      if (status.isGranted) {
        final name = await GetIt.I.get<INetworkInfoDriver>().getWifiName();
        if (mounted) {
          setState(() {
            _wifiName = name?.replaceAll('"', '');
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching Wi-Fi name: $e');
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppColors.primary),
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
                      label: const Text('PREMIUM'),
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
                  label: const Text('Upgrade'),
                  style: TextButton.styleFrom(foregroundColor: Colors.amber),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Showcase(
                  key: _wifiKey,
                  description: l10n.lobbyWifiShowcase,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.wifi_rounded, color: AppColors.error),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _wifiName != null 
                                ? l10n.lobbyWifiBannerConnected(_wifiName!) 
                                : l10n.lobbyWifiBannerDefault,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                        if (_wifiName == null)
                          TextButton(
                            onPressed: _fetchWifiName,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.error,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: Size.zero,
                            ),
                            child: Text(l10n.revealNetwork, style: const TextStyle(fontWeight: FontWeight.bold)),
                          )
                        else
                          TextButton(
                            onPressed: () => AppSettings.openAppSettings(type: AppSettingsType.wifi),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.error,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: Size.zero,
                            ),
                            child: Text(l10n.buttonWifi, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ),
                ),
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
    );
  }
}
