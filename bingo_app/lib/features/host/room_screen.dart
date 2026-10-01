import 'dart:async';
import 'dart:developer';

import 'package:bingo_app/features/host/host_room_view_model.dart';
import 'package:bingo_app/features/host/widgets/host_room_view.dart';
import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/services/ad_service.dart';
import 'package:bingo_app/shared/services/revenue_config_service.dart';
import 'package:bingo_app/shared/services/subscription_service.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart' show AppColors;
import 'package:bingo_app/shared/ui/widgets/config_listenable_builder.dart';
import 'package:bingo_app/shared/ui/widgets/view_model_provider.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class HostRoomScreen extends StatefulWidget {
  const HostRoomScreen({super.key});

  @override
  State<HostRoomScreen> createState() => _HostRoomScreenState();
}

class _HostRoomScreenState extends State<HostRoomScreen> {
  StreamSubscription<HostRoomAction>? _actionsSub;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    _actionsSub?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    // Cores, contorno e tipografia vêm do DialogThemeData/TextButtonTheme.
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.stopRoomTitle),
          content: Text(l10n.stopRoomMessage),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.no),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child: Text(l10n.yes),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  /// Encerra a sala (ROOM_CLOSED para todos) e volta ao lobby, passando pelo
  /// interstitial quando os anúncios estiverem ativos.
  Future<void> _endRoom(HostRoomViewModel viewModel) async {
    await viewModel.stopGame();
    if (!mounted) return;
    // AdService.canShowAds já cobre ads_enabled, premium (cache) e plataforma.
    if (AdService.canShowAds) {
      AdService.showInterstitialAd(
        onAdDismissed: () {
          if (mounted) context.go('/lobby');
        },
      );
    } else {
      context.go('/lobby');
    }
  }

  Future<void> _onExit(HostRoomViewModel viewModel) async {
    // Com a rodada encerrada não há o que perder: sai sem confirmar.
    final shouldPop = viewModel.isGameOver || await _showExitDialog(context);
    if (shouldPop && mounted) {
      await _endRoom(viewModel);
    }
  }

  /// Toast neutro logo acima do rodapé de sortear (o Scaffold já o ergue
  /// sobre a barra): não pode cobrir a ação principal do cantador entre uma
  /// bola e outra.
  void _showToast(ScaffoldMessengerState messenger, Key key, String text) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          key: key,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          duration: const Duration(seconds: 2),
          content: Text(text),
        ),
      );
  }

  void _onAction(HostRoomAction action, AppLocalizations l10n) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    switch (action) {
      case ShowPaywall(:final source):
        context.push('/paywall?source=$source');
      case ShowError(:final error):
        final text = switch (error) {
          HostRoomError.invalidNumber => l10n.errorInvalidNumber,
          HostRoomError.alreadyDrawn => l10n.errorNumberDrawn,
          HostRoomError.connection => l10n.hostRoomErrorConnection,
        };
        // Rosa de fundo + texto preto (SnackBarThemeData).
        messenger.showSnackBar(
          SnackBar(content: Text(text), backgroundColor: AppColors.error),
        );
      case AnnounceNumber(:final number, :final phrase):
        _showToast(
          messenger,
          const Key('host_announce_toast'),
          '${BingoCard.label(number)}  ·  $phrase',
        );
      case AnnounceUndo(:final number):
        _showToast(
          messenger,
          const Key('host_undo_toast'),
          l10n.hostRoomUndone(BingoCard.label(number)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ViewModelProvider<HostRoomViewModel>(
      onReady: (viewModel) {
        if (AdService.canShowAds) {
          AdService.loadInterstitialAd(
            onAdLoaded: () {
              if (kDebugMode) log('HostRoomScreen: interstitial carregado.');
            },
            onAdFailedToLoad: (error) {
              if (kDebugMode) {
                log('HostRoomScreen: interstitial falhou: $error');
              }
            },
          );
        }
        _actionsSub = viewModel.actionStream.listen(
          (action) => _onAction(action, l10n),
        );
      },
      builder: (context, viewModel, child) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) _onExit(viewModel);
          },
          // "N/M" + "jogadores (plano grátis)" quando há limite e o host não
          // é premium (modelo paywall_host). Reconstrói quando as flags
          // mudam ao vivo (override em /debug/flags).
          child: ConfigListenableBuilder(
            builder: (context) => ValueListenableBuilder<bool>(
              valueListenable: SubscriptionService.isPremium,
              builder: (context, isPremium, _) {
                final showCap =
                    RevenueConfigService.hasFreePlayerCap && !isPremium;
                return HostRoomView(
                  viewModel: viewModel,
                  onExit: () => _onExit(viewModel),
                  onEndRoom: () => _endRoom(viewModel),
                  maxPlayers: showCap
                      ? RevenueConfigService.maxFreePlayersPathA
                      : null,
                  purchasesEnabled: RevenueConfigService.purchasesEnabled,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
