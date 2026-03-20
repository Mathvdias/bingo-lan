import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/providers/locale_provider.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String? _wifiName;

  @override
  void initState() {
    super.initState();
    _fetchWifiName();
  }

  Future<void> _fetchWifiName() async {
    try {
      final status = await Permission.locationWhenInUse.request();
      if (status.isGranted) {
        final name = await GetIt.I.get<INetworkInfoDriver>().getWifiName();
        if (mounted) {
          setState(() {
            _wifiName = name?.replaceAll('"', '');
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching Wi-Fi name: $e');
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
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return BingoScaffold(
      title: l10n.aboutTitle,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.info_outline, size: 64, color: AppColors.primary),
            const SizedBox(height: 24),

            Text(
              l10n.aboutImportantTitle,
              style: textTheme.headlineSmall?.copyWith(color: AppColors.error),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wifi_rounded, color: AppColors.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _wifiName != null
                          ? l10n.lobbyWifiBannerConnected(_wifiName!)
                          : l10n.lobbyWifiBannerDefault,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  if (_wifiName == null)
                    TextButton(
                      onPressed: _fetchWifiName,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                      ),
                      child: Text(
                        l10n.revealNetwork,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  else
                    TextButton(
                      onPressed: () => AppSettings.openAppSettings(type: AppSettingsType.wifi),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                      ),
                      child: Text(
                        l10n.buttonWifi,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
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
                  'https://mathvdias.github.io/bingo-privacy-policy/',
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
                  'https://mathvdias.github.io/bingo-terms-of-use/',
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
          CircleAvatar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            radius: 16,
            child: Text(
              number,
              style: const TextStyle(fontWeight: FontWeight.bold),
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
