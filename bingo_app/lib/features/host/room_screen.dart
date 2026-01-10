import 'package:flutter/material.dart';

class HostRoomScreen extends StatelessWidget {
  const HostRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sala do Bingo'),
      ),
      body: const Center(
        child: Text('Tela da Sala do Host (Globo e Validação)'),
      ),
    );
  }
}
