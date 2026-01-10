import 'package:flutter/material.dart';

class PlayerGameScreen extends StatelessWidget {
  const PlayerGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sua Cartela'),
      ),
      body: const Center(
        child: Text('Tela do Jogo (A Cartela)'),
      ),
    );
  }
}
