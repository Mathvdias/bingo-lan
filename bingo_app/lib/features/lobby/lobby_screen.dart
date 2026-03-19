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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Premium badge or upgrade button
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
                Text(
                  'Bingo da Galera',
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
