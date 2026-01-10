import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
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
                    context.push('/host/setup'); // Changed from .go to .push
                  },
                ),
                const SizedBox(height: 24),
                BingoButton(
                  label: 'Entrar em um Bingo',
                  onPressed: () {
                    context.push('/player/scan'); // Changed from .go to .push
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
