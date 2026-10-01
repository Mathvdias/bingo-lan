import 'package:app_settings/app_settings.dart';
import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/providers/locale_provider.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_scaffold.dart';
import 'package:bingo_app/shared/ui/widgets/warning_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  void initState() {
    super.initState();
  }

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
      title: l10n.aboutTitle,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ícone preto sobre disco amarelo: o amarelo é fundo, não traço.
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.outline, width: 2),
                  boxShadow: const [
                    BoxShadow(color: AppColors.outline, offset: Offset(4, 4)),
                  ],
                ),
                child: const Icon(
                  Icons.info_outline,
                  size: 40,
                  color: AppColors.text,
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              l10n.aboutImportantTitle,
              style: textTheme.headlineSmall?.copyWith(
                color: AppColors.warningText,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.aboutImportantBody,
              style: textTheme.bodyLarge,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 32),

            // Wi-Fi Status Card
            WarningBox(
              text: l10n.lobbyWifiBannerDefault,
              actionLabel: l10n.buttonWifi,
              onAction: () =>
                  AppSettings.openAppSettings(type: AppSettingsType.wifi),
            ),
            const SizedBox(height: 32),

            Text(
              l10n.aboutHowToPlayTitle,
              style: textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildStep(context, '1', l10n.aboutStep1Title, l10n.aboutStep1Desc),
            _buildStep(context, '2', l10n.aboutStep2Title, l10n.aboutStep2Desc),
            _buildStep(context, '3', l10n.aboutStep3Title, l10n.aboutStep3Desc),
            _buildStep(context, '4', l10n.aboutStep4Title, l10n.aboutStep4Desc),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            Text(
              l10n.aboutLanguage,
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Consumer<LocaleProvider>(
              builder: (context, localeProvider, child) {
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  initialValue: localeProvider.locale?.languageCode ?? 'en',
                  items: const [
                    DropdownMenuItem(
                      value: 'en',
                      child: Text('English (US) 🇺🇸'),
                    ),
                    DropdownMenuItem(
                      value: 'pt',
                      child: Text('Português (BR) 🇧🇷'),
                    ),
                    DropdownMenuItem(
                      value: 'es',
                      child: Text('Español (ES) 🇪🇸'),
                    ),
                    DropdownMenuItem(
                      value: 'fr',
                      child: Text('Français (FR) 🇫🇷'),
                    ),
                    DropdownMenuItem(
                      value: 'it',
                      child: Text('Italiano (IT) 🇮🇹'),
                    ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.privacy_tip,
                  color: AppColors.textSecondary,
                ),
                title: Text(l10n.privacyPolicy),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _launchUrl(
                  'https://bingo-policy-and-terms.vercel.app/privacy',
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.description,
                  color: AppColors.textSecondary,
                ),
                title: Text(l10n.termsOfUse),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _launchUrl(
                  'https://bingo-policy-and-terms.vercel.app/terms',
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.code, color: AppColors.textSecondary),
                title: Text(l10n.aboutDeveloper),
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

  Widget _buildStep(
    BuildContext context,
    String number,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.outline, width: 2),
            ),
            child: Text(
              number,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
