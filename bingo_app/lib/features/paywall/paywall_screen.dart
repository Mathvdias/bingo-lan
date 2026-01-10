import 'package:flutter/material.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seja PRO!'),
      ),
      body: const Center(
        child: Text('Tela de Pagamento'),
      ),
    );
  }
}
