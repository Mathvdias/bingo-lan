import 'package:flutter/material.dart';

class MegafoneScreen extends StatelessWidget {
  const MegafoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Megafone'),
      ),
      body: const Center(
        child: Text('Tela do Megafone'),
      ),
    );
  }
}
