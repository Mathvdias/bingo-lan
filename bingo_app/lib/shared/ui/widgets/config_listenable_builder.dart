import 'package:bingo_app/shared/services/revenue_config_service.dart';
import 'package:flutter/material.dart';

/// Reconstrói [builder] quando as feature flags mudam ao vivo (override local
/// na tela `/debug/flags` ou novo fetch do Remote Config).
///
/// Em prod o driver de config não notifica nunca: o widget vira um
/// `ListenableBuilder` inerte, sem custo além da primeira montagem.
class ConfigListenableBuilder extends StatelessWidget {
  final WidgetBuilder builder;

  const ConfigListenableBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: RevenueConfigService.listenable,
      builder: (context, _) => builder(context),
    );
  }
}
