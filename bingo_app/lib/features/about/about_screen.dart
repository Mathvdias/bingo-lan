import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bingo_app/shared/providers/locale_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bingo_app/l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return BingoScaffold(
      title: 'Sobre o Bingo',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.info_outline, size: 64, color: AppColors.primary),
            const SizedBox(height: 24),
            
            Text(
              '⚠️ Importante: Mesma Rede Wi-Fi',
              style: textTheme.headlineSmall?.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'O Bingo funciona através de uma conexão local segura. Para que os jogadores encontrem a sua sala, TODOS (inclusive o organizador) devem estar conectados à mesma rede Wi-Fi.',
              style: textTheme.bodyLarge,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 32),

            Text(
              '📖 Como Jogar (Passo a Passo)',
              style: textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildStep(context, '1', 'Escolha o Organizador', 'Uma pessoa inicia a partida clicando em "Organizar um Bingo" e compartilha o Código da Sala.'),
            _buildStep(context, '2', 'Jogadores na Sala', 'Os demais participantes clicam em "Entrar" e digitam o código (ou apontam a câmera pro QR Code).'),
            _buildStep(context, '3', 'Marcando a Cartela', 'O organizador sorteia as bolas. Toque no número da sua cartela no celular para marcá-lo.'),
            _buildStep(context, '4', 'BINGO!', 'Completou a cartela? Aperte o botão "GRITAR BINGO" antes de todo mundo para vencer!'),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            
            Text(
              '🌐 Idioma / Language',
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Consumer<LocaleProvider>(
              builder: (context, localeProvider, child) {
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  value: localeProvider.locale?.languageCode ?? 'en',
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English (US) 🤔')),
                    DropdownMenuItem(value: 'pt', child: Text('Português (BR) 🇧🇷')),
                    DropdownMenuItem(value: 'es', child: Text('Español (ES) 🇪🇸')),
                    DropdownMenuItem(value: 'fr', child: Text('Français (FR) 🇫🇷')),
                    DropdownMenuItem(value: 'it', child: Text('Italiano (IT) 🇮🇹')),
                    DropdownMenuItem(value: 'ja', child: Text('日本語 (JA) 🇯🇵')),
                  ],
                  onChanged: (String? newLocale) {
                    if (newLocale != null) {
                      localeProvider.setLocale(Locale(newLocale));
                    }
                  },
                );
              },
            ),

            const SizedBox(height: 32),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.privacy_tip, color: AppColors.textSecondary),
                title: Text(l10n.privacyPolicy),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _launchUrl('https://mathvdias.github.io/bingo-privacy-policy/'),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.description, color: AppColors.textSecondary),
                title: Text(l10n.termsOfUse),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _launchUrl('https://mathvdias.github.io/bingo-terms-of-use/'),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.code, color: AppColors.textSecondary),
                title: const Text('Desenvolvedor (GitHub)'),
                subtitle: const Text('@Mathvdias'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _launchUrl('https://github.com/Mathvdias'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            radius: 16,
            child: Text(number, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
