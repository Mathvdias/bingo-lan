import 'package:flutter/material.dart';

class PlayerScanScreen extends StatelessWidget {
  const PlayerScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Procurar Sala'),
      ),
      body: const Center(
        child: Text('Tela de Scan do Player (Wi-Fi ou Código)'),
      ),
    );
  }
}
