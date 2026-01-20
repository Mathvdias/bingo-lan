import 'package:bingo_app/features/auth/auth_service.dart';
import 'package:bingo_app/shared/di/service_locator.dart';
import 'package:bingo_app/shared/services/analytics_service.dart';
import 'package:bingo_app/shared/services/subscription_service.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  bool _isPremium = false;
  bool _checkingSubscription = true;

  @override
  void initState() {
    super.initState();
    _checkSubscription();
  }

  Future<void> _checkSubscription() async {
    setState(() => _checkingSubscription = true);
    try {
      final hasSub = await SubscriptionService.hasActiveSubscription();
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

  Future<void> _logout() async {
    try {
      final authService = serviceLocator<AuthService>();
      await authService.signOut();

      // Track logout
      await AnalyticsService.trackCustomEvent('user_logout', null);

      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao fazer logout: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final authService = serviceLocator<AuthService>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Premium badge or upgrade button
          if (_checkingSubscription)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_isPremium)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Chip(
                label: const Text('PREMIUM'),
                backgroundColor: Colors.amber,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: () => context.push('/paywall'),
              icon: const Icon(Icons.star, color: Colors.amber),
              label: const Text('Upgrade'),
              style: TextButton.styleFrom(foregroundColor: Colors.amber),
            ),

          // User menu
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundImage: authService.userPhotoUrl != null
                  ? NetworkImage(authService.userPhotoUrl!)
                  : null,
              child: authService.userPhotoUrl == null
                  ? Text(
                      authService.userDisplayName
                              ?.substring(0, 1)
                              .toUpperCase() ??
                          'U',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              } else if (value == 'paywall') {
                context.push('/paywall');
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authService.userDisplayName ?? 'Usuário',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      authService.userEmail ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              if (!_isPremium)
                const PopupMenuItem(
                  value: 'paywall',
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      SizedBox(width: 8),
                      Text('Assinar Premium'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Sair'),
                  ],
                ),
              ),
            ],
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
                Text(
                  'Bingo Lucca',
                  textAlign: TextAlign.center,
                  style: textTheme.displayLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sua festa, suas regras',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: const Color.fromRGBO(18, 18, 18, 0.7),
                  ),
                ),
                const SizedBox(height: 64),
                BingoButton(
                  label: 'Organizar um Bingo',
                  onPressed: () {
                    context.push('/host/setup');
                  },
                ),
                const SizedBox(height: 24),
                BingoButton(
                  label: 'Entrar em um Bingo',
                  onPressed: () {
                    context.push('/player/scan');
                  },
                  color: colorScheme.secondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
