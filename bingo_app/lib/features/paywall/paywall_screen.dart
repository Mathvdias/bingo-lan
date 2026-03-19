import 'package:bingo_app/features/paywall/paywall_view_model.dart';
import 'package:bingo_app/shared/di/service_locator.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = serviceLocator<PaywallViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.isPro) {
              return _buildAlreadyProView(context);
            }

            return _buildPaywallView(context, viewModel);
          },
        ),
      ),
    );
  }

  Widget _buildAlreadyProView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_rounded, size: 120, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              'Você já é Premium!',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Aproveite todos os recursos ilimitados',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/lobby'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Continuar',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaywallView(BuildContext context, PaywallViewModel viewModel) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close),
              ),
            ),

            const SizedBox(height: 8),

            // Header
            Column(
              children: [
                const Icon(Icons.casino, size: 80, color: AppColors.primary),
                const SizedBox(height: 16),
                Text(
                  'Desbloqueie Premium',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Jogue bingo sem limites',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Features
            _buildPremiumFeature(Icons.all_inclusive, 'Salas ilimitadas'),
            _buildPremiumFeature(Icons.auto_awesome, 'Globo automático'),
            _buildPremiumFeature(Icons.palette, 'Temas personalizados'),
            _buildPremiumFeature(Icons.bar_chart, 'Estatísticas avançadas'),
            _buildPremiumFeature(Icons.block, 'Sem anúncios'),

            const SizedBox(height: 32),

            // Pricing plans
            if (viewModel.offerings != null &&
                viewModel.offerings!.current != null)
              ...viewModel.offerings!.current!.availablePackages.map((package) {
                return _buildPricingCard(
                  context,
                  viewModel,
                  package,
                  isSelected:
                      viewModel.selectedPackage?.identifier ==
                      package.identifier,
                );
              }).toList()
            else if (viewModel.errorMessage != null)
              Center(
                child: Column(
                  children: [
                    Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: viewModel.fetchOfferings,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              )
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Carregando planos...'),
                      SizedBox(height: 8),
                      Text(
                        'Dica: Verifique se as Offerings estão configuradas como "Current" no RevenueCat.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Error message
            if (viewModel.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error),
                ),
                child: Text(
                  viewModel.errorMessage!,
                  style: TextStyle(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ),

            // Purchase button
            ElevatedButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () async {
                      final success = await viewModel.purchase();
                      if (success && context.mounted) {
                        context.go('/lobby');
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: viewModel.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Começar teste grátis de 7 dias',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),

            const SizedBox(height: 16),

            // Restore button
            TextButton(
              onPressed: viewModel.isLoading ? null : viewModel.restore,
              child: Text(
                'Restaurar compras',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Terms
            Text(
              'Termos de Uso e Política de Privacidade',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumFeature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 16),
          Text(
            text,
            style: GoogleFonts.poppins(fontSize: 16, color: AppColors.text),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(
    BuildContext context,
    PaywallViewModel viewModel,
    Package package, {
    required bool isSelected,
  }) {
    final savings = viewModel.getSavings(package);
    final isAnnual = package.identifier.contains('annual');

    return GestureDetector(
      onTap: () => viewModel.selectPackage(package),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.outline.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Radio button
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 16),

            // Plan info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        package.storeProduct.title.split('(').first.trim(),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      if (isAnnual) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'POPULAR',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (savings != null)
                    Text(
                      savings,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),

            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  viewModel.getPrice(package),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  viewModel.getBillingPeriod(package),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
