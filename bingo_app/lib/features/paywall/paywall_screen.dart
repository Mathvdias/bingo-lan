import 'package:bingo_app/features/paywall/paywall_view_model.dart';
import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/di/service_locator.dart';
import 'package:bingo_app/shared/services/ad_service.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:bingo_app/shared/ui/widgets/stroked_text.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

const String _termsUrl = 'https://bingo-policy-and-terms.vercel.app/terms';
const String _privacyUrl = 'https://bingo-policy-and-terms.vercel.app/privacy';

/// Paywall próprio. Renderiza o que `offerings.current` devolver.
///
/// Retorna `true` no `pop` quando a compra ou o restore ativam o premium.
class PaywallScreen extends StatefulWidget {
  /// Origem para analytics (`lobby`, `auto_globe`, `room_capacity`...).
  final String source;

  const PaywallScreen({super.key, this.source = 'unknown'});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  late final PaywallViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    AdService.suppressFullScreenAds = true;
    _viewModel = serviceLocator<PaywallViewModel>();
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.start(widget.source);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    AdService.suppressFullScreenAds = false;
    super.dispose();
  }

  void _onViewModelChanged() {
    // Erros de carregamento ficam na própria tela (estado `error`).
    if (_viewModel.state == PaywallState.error) return;
    final error = _viewModel.consumeError();
    if (error == null || !mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final message = switch (error) {
      PaywallError.loadFailed => l10n.paywallErrorLoad,
      PaywallError.purchaseFailed => l10n.paywallErrorPurchase,
      PaywallError.restoreFailed => l10n.paywallErrorRestore,
      PaywallError.restoreNothing => l10n.paywallRestoreNothing,
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error == PaywallError.restoreNothing
            ? AppColors.outline
            : AppColors.error,
      ),
    );
  }

  void _close([bool result = false]) {
    if (!mounted) return;
    if (context.canPop()) {
      context.pop(result);
    } else {
      context.go('/lobby');
    }
  }

  Future<void> _purchase() async {
    final granted = await _viewModel.purchase();
    if (granted) _close(true);
  }

  Future<void> _restore() async {
    final granted = await _viewModel.restore();
    if (granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.paywallRestoreSuccess),
          backgroundColor: AppColors.success,
        ),
      );
      _close(true);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: _CloseButton(
                    tooltip: l10n.paywallClose,
                    onPressed: _viewModel.state == PaywallState.purchasing
                        ? null
                        : () => _close(false),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Hero(l10n: l10n),
                        const SizedBox(height: 24),
                        _Benefits(l10n: l10n),
                        const SizedBox(height: 24),
                        _buildBody(context, l10n),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    switch (_viewModel.state) {
      case PaywallState.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.outline),
          ),
        );
      case PaywallState.empty:
        return _Message(
          icon: Icons.inventory_2_outlined,
          message: l10n.paywallEmpty,
          retryLabel: l10n.paywallRetry,
          onRetry: _viewModel.load,
          restoreLabel: l10n.paywallRestore,
          onRestore: _restore,
        );
      case PaywallState.error:
        return _Message(
          icon: Icons.cloud_off_outlined,
          message: l10n.paywallErrorLoad,
          retryLabel: l10n.paywallRetry,
          onRetry: _viewModel.load,
          restoreLabel: l10n.paywallRestore,
          onRestore: _restore,
        );
      case PaywallState.ready:
      case PaywallState.purchasing:
        return _Plans(
          viewModel: _viewModel,
          l10n: l10n,
          onPurchase: _purchase,
          onRestore: _restore,
          onOpenTerms: () => _launchUrl(_termsUrl),
          onOpenPrivacy: () => _launchUrl(_privacyUrl),
        );
    }
  }
}

// --------------------------------------------------------------------- Peças

class _CloseButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String tooltip;

  const _CloseButton({required this.onPressed, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          key: const Key('paywall_close'),
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.outline, width: 2),
            ),
            child: Icon(
              Icons.close,
              size: 20,
              color: onPressed == null
                  ? AppColors.textSecondary
                  : AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final AppLocalizations l10n;
  const _Hero({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        // Roseta 3D (76 px, o mesmo que o disco amarelo de antes, que fica
        // como placeholder até o bundle carregar).
        BingoLavaIconView(
          key: const Key('paywall_hero_badge'),
          icon: BingoLavaIcon.premiumBadge,
          size: 76,
          fallback: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.outline, width: 2),
              boxShadow: const [
                BoxShadow(color: AppColors.outline, offset: Offset(4, 4)),
              ],
            ),
            child: const Icon(
              Icons.workspace_premium,
              size: 40,
              color: AppColors.text,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Semantics(
          header: true,
          child: StrokedText(
            text: l10n.paywallHeroTitle,
            style: textTheme.displayLarge,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.paywallHeroSubtitle,
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _Benefits extends StatelessWidget {
  final AppLocalizations l10n;
  const _Benefits({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BenefitRow(
          icon: Icons.groups_rounded,
          lava: BingoLavaIcon.players,
          text: l10n.paywallBenefitUnlimitedPlayers,
        ),
        const SizedBox(height: 12),
        _BenefitRow(
          icon: Icons.autorenew_rounded,
          text: l10n.paywallBenefitAutoGlobe,
        ),
        const SizedBox(height: 12),
        _BenefitRow(icon: Icons.block_rounded, text: l10n.paywallBenefitNoAds),
      ],
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;

  /// Ícone Lava no lugar do disco azul com [icon] (que fica de fallback).
  final BingoLavaIcon? lava;
  final String text;
  const _BenefitRow({required this.icon, this.lava, required this.text});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // 36 px: o disco (8 + 20 + 8) e o ícone Lava têm a mesma caixa.
    final badge = Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.outline, width: 2),
      ),
      child: Icon(icon, size: 20, color: AppColors.text),
    );
    final lavaIcon = lava;
    return Row(
      children: [
        if (lavaIcon == null)
          badge
        else
          BingoLavaIconView(
            key: Key('paywall_benefit_${lavaIcon.name}'),
            icon: lavaIcon,
            size: 36,
            fallback: badge,
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;
  final String restoreLabel;
  final VoidCallback onRestore;

  const _Message({
    required this.icon,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
    required this.restoreLabel,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Icon(icon, size: 48, color: AppColors.textSecondary),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center, style: textTheme.bodyLarge),
        const SizedBox(height: 16),
        BingoButton(
          key: const Key('paywall_retry'),
          label: retryLabel,
          onPressed: onRetry,
        ),
        const SizedBox(height: 8),
        TextButton(
          key: const Key('paywall_restore'),
          onPressed: onRestore,
          style: TextButton.styleFrom(foregroundColor: AppColors.text),
          child: Text(restoreLabel),
        ),
      ],
    );
  }
}

class _Plans extends StatelessWidget {
  final PaywallViewModel viewModel;
  final AppLocalizations l10n;
  final VoidCallback onPurchase;
  final VoidCallback onRestore;
  final VoidCallback onOpenTerms;
  final VoidCallback onOpenPrivacy;

  const _Plans({
    required this.viewModel,
    required this.l10n,
    required this.onPurchase,
    required this.onRestore,
    required this.onOpenTerms,
    required this.onOpenPrivacy,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final purchasing = viewModel.state == PaywallState.purchasing;
    final selected = viewModel.selectedPackage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final package in viewModel.packages) ...[
          _PackageCard(
            package: package,
            selected: package == selected,
            enabled: !purchasing,
            l10n: l10n,
            savingsPercent: viewModel.savingsPercentFor(package),
            onTap: () => viewModel.selectPackage(package),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 8),
        _Disabled(
          disabled: purchasing || selected == null,
          child: BingoButton(
            key: const Key('paywall_cta'),
            label: l10n.paywallCta(selected?.storeProduct.priceString ?? ''),
            onPressed: onPurchase,
          ),
        ),
        if (purchasing) ...[
          const SizedBox(height: 16),
          const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.outline,
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        TextButton(
          key: const Key('paywall_restore'),
          onPressed: purchasing ? null : onRestore,
          style: TextButton.styleFrom(foregroundColor: AppColors.text),
          child: Text(l10n.paywallRestore),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.paywallLegal,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TextButton(
              onPressed: onOpenTerms,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
              child: Text(l10n.termsOfUse),
            ),
            const Text('·', style: TextStyle(color: AppColors.textSecondary)),
            TextButton(
              onPressed: onOpenPrivacy,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
              child: Text(l10n.privacyPolicy),
            ),
          ],
        ),
      ],
    );
  }
}

class _Disabled extends StatelessWidget {
  final bool disabled;
  final Widget child;
  const _Disabled({required this.disabled, required this.child});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: disabled,
      child: Opacity(opacity: disabled ? 0.5 : 1, child: child),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final Package package;
  final bool selected;
  final bool enabled;
  final AppLocalizations l10n;
  final int? savingsPercent;
  final VoidCallback onTap;

  const _PackageCard({
    required this.package,
    required this.selected,
    required this.enabled,
    required this.l10n,
    required this.savingsPercent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final product = package.storeProduct;
    final isLifetime = package.packageType == PackageType.lifetime;
    final periodLabel = _periodLabel(l10n, package.packageType);
    final detail = isLifetime
        ? l10n.paywallOneTimePayment
        : _periodSuffix(l10n, package.packageType);

    return Semantics(
      button: true,
      selected: selected,
      label: '$periodLabel ${product.priceString}',
      child: InkWell(
        key: Key('paywall_package_${package.identifier}'),
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            // Cor opaca: com fill translúcido a sombra preta de baixo aparecia.
            color: selected
                ? Color.alphaBlend(
                    AppColors.primary.withValues(alpha: 0.25),
                    AppColors.card,
                  )
                : AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.outline,
              width: selected ? 3 : 2,
            ),
            boxShadow: selected
                ? const [
                    BoxShadow(color: AppColors.outline, offset: Offset(3, 3)),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: AppColors.text,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          periodLabel,
                          style: textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (savingsPercent != null)
                          _Badge(text: l10n.paywallSavings(savingsPercent!)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                product.priceString,
                textAlign: TextAlign.end,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _periodLabel(AppLocalizations l10n, PackageType type) {
    return switch (type) {
      PackageType.weekly => l10n.paywallPeriodWeekly,
      PackageType.monthly => l10n.paywallPeriodMonthly,
      PackageType.twoMonth => l10n.paywallPeriodTwoMonth,
      PackageType.threeMonth => l10n.paywallPeriodThreeMonth,
      PackageType.sixMonth => l10n.paywallPeriodSixMonth,
      PackageType.annual => l10n.paywallPeriodAnnual,
      PackageType.lifetime => l10n.paywallPeriodLifetime,
      PackageType.custom || PackageType.unknown => l10n.paywallPeriodCustom,
    };
  }

  static String _periodSuffix(AppLocalizations l10n, PackageType type) {
    return switch (type) {
      PackageType.weekly => l10n.paywallBilledWeekly,
      PackageType.monthly => l10n.paywallBilledMonthly,
      PackageType.twoMonth => l10n.paywallBilledTwoMonth,
      PackageType.threeMonth => l10n.paywallBilledThreeMonth,
      PackageType.sixMonth => l10n.paywallBilledSixMonth,
      PackageType.annual => l10n.paywallBilledAnnual,
      PackageType.lifetime => l10n.paywallOneTimePayment,
      PackageType.custom || PackageType.unknown => l10n.paywallBilledCustom,
    };
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outline, width: 1.5),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.text,
        ),
      ),
    );
  }
}
