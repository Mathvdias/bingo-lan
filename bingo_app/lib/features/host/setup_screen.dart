import 'package:bingo_app/features/host/host_setup_view_model.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_scaffold.dart';
import 'package:bingo_app/shared/ui/widgets/flippable_card.dart';
import 'package:bingo_app/shared/ui/widgets/view_model_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HostSetupScreen extends StatelessWidget {
  const HostSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ViewModelProvider<HostSetupViewModel>(
      onReady: (viewModel) {
        // Listen for error messages to show a Snackbar
        viewModel.addListener(() {
          if (viewModel.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(viewModel.errorMessage!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        });
      },
      builder: (context, viewModel, child) {
        return BingoScaffold(
          title: 'Organizar um Bingo',
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Dê um nome para a sala',
                        style: textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        onChanged: viewModel.onRoomNameChanged,
                        decoration: InputDecoration(
                          hintText: 'Ex: Bingo do Tio Zé',
                          errorText: viewModel.errorMessage,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const SizedBox(height: 32),
                      FlippableCard(
                        image: 'assets/images/bingo_local.png',
                        text: 'Jogue com pessoas na mesma rede Wi-Fi. Ideal para festas e encontros.',
                      ),
                      const SizedBox(height: 32),
                      BingoButton(
                        label: 'Criar Sala',
                        onPressed: () async {
                          final qrData = await viewModel.createRoom();
                          if (qrData != null && context.mounted) {
                            context.push(
                              '/host/invite',
                              extra: qrData,
                            ); // Changed from .go to .push
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
