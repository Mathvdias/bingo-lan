import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/players_counter.dart';
import 'package:bingo_app/shared/ui/widgets/stroked_text.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:flutter/material.dart';

/// Cabeçalho da sala do host: última bola (ou estado vazio), histórico,
/// desfazer e contador de jogadores.
///
/// Widget puro (sem ViewModel) para poder ser testado com escala de texto
/// grande sem Firebase nem plugins.
class HostDrawPanel extends StatelessWidget {
  final int? lastNumber;

  /// Histórico do mais recente para o mais antigo.
  final List<int> drawnNumbersNewestFirst;
  final bool canUndo;
  final VoidCallback? onUndo;
  final int playerCount;

  /// Limite do plano grátis; `null` quando não há limite a mostrar.
  final int? maxPlayers;

  /// Altura da faixa do histórico, reservada mesmo sem bolas.
  static const double _historyHeight = 52;

  const HostDrawPanel({
    super.key,
    required this.lastNumber,
    required this.drawnNumbersNewestFirst,
    required this.canUndo,
    required this.onUndo,
    required this.playerCount,
    this.maxPlayers,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final last = lastNumber;
    final history = drawnNumbersNewestFirst;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outline, width: 2),
            ),
            // Os dois estados são sempre medidos (o inativo fica invisível):
            // a altura do cartão não muda quando a primeira bola sai e o
            // botão SORTEAR fica onde estava, em qualquer escala de texto.
            child: Stack(
              alignment: Alignment.center,
              children: [
                Visibility(
                  visible: last == null,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: _EmptyState(
                    key: last == null ? const Key('host_empty_state') : null,
                    l10n: l10n,
                    textTheme: textTheme,
                    // Escondido (já saiu bola) o globo não precisa animar.
                    animated: last == null,
                  ),
                ),
                Visibility(
                  visible: last != null,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: _DrawnState(
                    // Sem bola ainda: mede com um rótulo qualquer.
                    label: BingoCard.label(last ?? 75),
                    count: l10n.drawnCount(history.length),
                    numberKey: last == null
                        ? null
                        : const Key('host_last_number'),
                    countKey: last == null
                        ? null
                        : const Key('host_drawn_count'),
                    textTheme: textTheme,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Histórico (mais recente primeiro). A faixa reserva a altura mesmo
          // vazia para nada abaixo se mover na primeira bola.
          SizedBox(
            height: _historyHeight,
            child: history.isEmpty
                ? const SizedBox.shrink(key: Key('host_history_placeholder'))
                : ListView.builder(
                    key: const Key('host_history'),
                    scrollDirection: Axis.horizontal,
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final number = history[index];
                      final isLatest = index == 0;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isLatest
                              ? AppColors.primary
                              : AppColors.success,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.outline,
                            width: isLatest ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              BingoCard.label(number),
                              style: textTheme.bodyLarge?.copyWith(
                                color: AppColors.text,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          // Desfazer fica sempre no mesmo lugar; desabilitado quando não há
          // bola para tirar ou o globo automático está rodando.
          OutlinedButton.icon(
            key: const Key('host_undo_button'),
            onPressed: canUndo ? onUndo : null,
            icon: const Icon(Icons.undo),
            label: Text(l10n.hostRoomUndoLast),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              textStyle: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          PlayersCounter(
            key: const Key('host_room_player_count'),
            count: playerCount,
            max: maxPlayers,
          ),
        ],
      ),
    );
  }
}

/// Última bola sorteada em destaque + "N/75 sorteados".
class _DrawnState extends StatelessWidget {
  final String label;
  final String count;
  final Key? numberKey;
  final Key? countKey;
  final TextTheme textTheme;

  const _DrawnState({
    required this.label,
    required this.count,
    required this.numberKey,
    required this.countKey,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // FittedBox: "G-75" a 120 px cabe em qualquer largura e em qualquer
        // escala de texto sem estourar.
        FittedBox(
          fit: BoxFit.scaleDown,
          child: StrokedText(
            key: numberKey,
            text: label,
            style: textTheme.headlineLarge,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          count,
          key: countKey,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

/// Estado vazio: globo de bingo 3D girando no eixo, com bolas dentro (bola
/// em contorno com "—" até o bundle carregar), título e instrução. Substitui
/// o "--" gigante amarelo que parecia duas pílulas.
class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  final TextTheme textTheme;
  final bool animated;

  /// Lado do globo (120 px: o bundle é renderizado em 2x para isso); o
  /// placeholder tem o mesmo tamanho para o cartão não mudar de altura entre
  /// os dois estados.
  static const double _heroSize = 120;

  const _EmptyState({
    super.key,
    required this.l10n,
    required this.textTheme,
    this.animated = true,
  });

  Widget _placeholder() {
    return Container(
      width: _heroSize,
      height: _heroSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.outline, width: 3),
        boxShadow: const [
          BoxShadow(color: AppColors.outline, offset: Offset(4, 4)),
        ],
      ),
      child: ExcludeSemantics(
        child: Text(
          '—',
          style: textTheme.headlineMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (animated)
          BingoLavaIconView(
            key: const Key('host_empty_cage'),
            icon: BingoLavaIcon.cage,
            size: _heroSize,
            fallback: _placeholder(),
          )
        else
          SizedBox.square(dimension: _heroSize, child: _placeholder()),
        const SizedBox(height: 12),
        Text(
          l10n.hostRoomEmptyTitle,
          textAlign: TextAlign.center,
          style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.hostRoomWaitingDraw,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
