import 'package:flutter/material.dart';

class HostSetupScreen extends StatelessWidget {
  const HostSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Sala'),
      ),
      body: const Center(
        child: Text('Tela de Setup do Host (Local vs Online)'),
      ),
    );
  }
}
