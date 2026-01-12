import 'package:bingo_app/features/paywall/paywall_view_model.dart';
import 'package:bingo_app/shared/di/service_locator.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_scaffold.dart';
import 'package:flutter/material.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Resolve ViewModel
    final viewModel = serviceLocator<PaywallViewModel>();
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
                        return BingoScaffold(
                          title: 'Seja PRO!',
                          body: CustomScrollView(
                            slivers: [
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        size: 100,
                                        color: AppColors.pastelYellow,
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        'Desbloqueie o Bingo Lucca PRO',
                                        style: textTheme.displaySmall,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Remova limites, habilite partidas online ilimitadas e use o Megafone!',
                                        style: textTheme.bodyLarge,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 64),
                                      if (viewModel.isPro)
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: AppColors.success,
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            'Você já é PRO!',
                                            style: textTheme.headlineSmall?.copyWith(
                                              color: AppColors.text,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      else ...[
                                        if (viewModel.errorMessage != null)
                                          Text(
                                            viewModel.errorMessage!,
                                            style: textTheme.bodyMedium?.copyWith(
                                              color: AppColors.error,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        const SizedBox(height: 16),
                                        BingoButton(
                                          label: 'Comprar PRO',
                                          onPressed: viewModel.purchase,
                                        ),
                                        const SizedBox(height: 16),
                                        TextButton(
                                          onPressed: viewModel.restore,
                                          child: const Text('Restaurar Compras'),
                                        ),
                                      ],
                                      const SizedBox(height: 32),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );      },
    );
  }
}
