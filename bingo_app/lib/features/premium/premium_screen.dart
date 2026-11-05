import 'dart:io';

import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/services/subscription_service.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_scaffold.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// O que o assinante ganhou. Antes, quem já era premium só via um selo
/// estático no lobby e não tinha onde conferir pelo que pagou.
///
/// Os benefícios aqui são os gates reais do app — sem anúncios
/// (`AdService`), globo automático (`HostRoomViewModel`) e sala sem o teto da
/// versão grátis (`RoomScreen`). Se um gate novo surgir, ele entra aqui.
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _restoring = false;

  static final Uri _androidSubscriptions = Uri.parse(
    'https://play.google.com/store/account/subscriptions',
  );
  static final Uri _iosSubscriptions = Uri.parse(
    'https://apps.apple.com/account/subscriptions',
  );

  Future<void> _openStoreSubscriptions() async {
    final uri = Platform.isIOS ? _iosSubscriptions : _androidSubscriptions;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _restore() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _restoring = true);

    final info = await SubscriptionService.restorePurchases();

    if (!mounted) return;
    setState(() => _restoring = false);

    final String message;
    if (info == null) {
      message = l10n.paywallErrorRestore;
    } else if (SubscriptionService.isPremium.value) {
      message = l10n.paywallRestoreSuccess;
    } else {
      message = l10n.paywallRestoreNothing;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return BingoScaffold(
      title: l10n.premiumTitle,
      body: ValueListenableBuilder<bool>(
        valueListenable: SubscriptionService.isPremium,
        builder: (context, isPremium, _) {
          return ListView(
            key: const ValueKey<String>('premium_screen'),
            padding: const EdgeInsets.all(24.0),
            children: [
              // Selo 3D do design system; até o bundle decodificar fica o
              // disco amarelo do mesmo tamanho, então nada pula.
              Center(
                child: BingoLavaIconView(
                  key: const Key('premium_hero_badge'),
                  icon: BingoLavaIcon.premiumBadge,
                  size: 88,
                  fallback: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.outline, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.outline,
                          offset: Offset(4, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      size: 48,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                isPremium ? l10n.premiumActiveTitle : l10n.paywallTitle,
                key: const Key('premium_headline'),
                style: textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isPremium
                    ? l10n.premiumActiveSubtitle
                    : l10n.paywallHeroSubtitle,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              _Benefit(
                icon: Icons.block_rounded,
                text: l10n.paywallBenefitNoAds,
                active: isPremium,
              ),
              _Benefit(
                icon: Icons.autorenew_rounded,
                text: l10n.paywallBenefitAutoGlobe,
                active: isPremium,
              ),
              _Benefit(
                icon: Icons.groups_rounded,
                text: l10n.paywallBenefitUnlimitedPlayers,
                active: isPremium,
              ),

              const SizedBox(height: 32),

              if (isPremium) ...[
                OutlinedButton.icon(
                  key: const Key('premium_manage_button'),
                  onPressed: _openStoreSubscriptions,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: Text(l10n.premiumManage),
                ),
                const SizedBox(height: 8),
                TextButton(
                  key: const Key('premium_restore_button'),
                  onPressed: _restoring ? null : _restore,
                  child: _restoring
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.paywallRestore),
                ),
              ] else
                // Chegou aqui sem assinatura (deep link, restauração expirada):
                // em vez de uma tela vazia, manda para a oferta.
                FilledButton(
                  key: const Key('premium_go_paywall_button'),
                  onPressed: () => context.push('/paywall?source=premium'),
                  child: Text(l10n.paywallHeroTitle),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Um benefício da lista: disco com ícone e o texto ao lado.
class _Benefit extends StatelessWidget {
  const _Benefit({
    required this.icon,
    required this.text,
    required this.active,
  });

  final IconData icon;
  final String text;

  /// Assinatura ativa: disco amarelo cheio. Sem assinatura: apenas contorno,
  /// deixando claro que ainda é promessa e não benefício em uso.
  final bool active;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.card,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.outline, width: 2),
            ),
            child: Icon(icon, size: 24, color: AppColors.text),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: textTheme.titleMedium)),
          if (active)
            const Icon(
              Icons.check_circle,
              color: AppColors.outline,
              size: 22,
            ),
        ],
      ),
    );
  }
}
