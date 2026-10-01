import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:flutter/material.dart';

/// Contador de jogadores em duas linhas: "0/10" grande e o rótulo embaixo.
///
/// Com [max] mostra a capacidade do plano grátis ("N/M" + "jogadores (plano
/// grátis)"); sem [max], só a contagem ("N" + "jogadores conectados"). Usado
/// na tela de convite e no cabeçalho da sala do host. O [FittedBox] evita
/// estouro com escala de texto grande.
class PlayersCounter extends StatelessWidget {
  final int count;
  final int? max;

  const PlayersCounter({super.key, required this.count, this.max});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final cap = max;
    final number = cap == null ? '$count' : '$count/$cap';
    final label = cap == null
        ? l10n.playersConnectedLabel
        : l10n.playersCapacityLabel;
    final semantics = cap == null
        ? l10n.inviteConnectedPlayers(count)
        : l10n.playersCapacity(count, cap);

    return Semantics(
      label: semantics,
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Dois jogadores 3D (um acena), 36 px para ler ao lado do
              // número; o ícone Material fica até o bundle carregar.
              const BingoLavaIconView(
                key: Key('players_counter_icon'),
                icon: BingoLavaIcon.players,
                size: 36,
                fallback: Icon(Icons.people, size: 28),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    number,
                    key: const Key('players_counter_number'),
                    style: textTheme.headlineMedium?.copyWith(
                      fontSize: 36,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Text(
            label,
            key: const Key('players_counter_label'),
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
