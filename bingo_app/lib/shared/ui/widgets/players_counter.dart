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
///
/// [compact] é a versão de uma linha para dividir espaço com um botão (sala
/// do host em 360x640 dp): ícone + "N/M", com o rótulo completo só na
/// semântica e no tooltip.
class PlayersCounter extends StatelessWidget {
  final int count;
  final int? max;
  final bool compact;

  const PlayersCounter({
    super.key,
    required this.count,
    this.max,
    this.compact = false,
  });

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

    if (compact) {
      return Semantics(
        label: semantics,
        excludeSemantics: true,
        child: Tooltip(
          message: semantics,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BingoLavaIconView(
                key: Key('players_counter_icon'),
                icon: BingoLavaIcon.players,
                size: 28,
                fallback: Icon(Icons.people, size: 22),
              ),
              const SizedBox(width: 6),
              Text(
                number,
                key: const Key('players_counter_number'),
                style: textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
