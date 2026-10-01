import 'dart:developer';

import 'package:app_settings/app_settings.dart';
import 'package:bingo_app/core/config/debug_tools.dart';
import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/providers/locale_provider.dart';
import 'package:bingo_app/shared/router.dart' show debugFlagsPath;
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_scaffold.dart';
import 'package:bingo_app/shared/ui/widgets/warning_box.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  /// Liga a entrada escondida (5 toques na versão abrem `/debug/flags`).
  /// Nulo = segue [debugToolsEnabled] (dev/alpha sim, prod não).
  final bool? debugTools;

  /// Relógio da janela de toques (injetável em teste).
  final DateTime Function()? now;

  const AboutScreen({super.key, this.debugTools, this.now});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  /// Toques na versão para abrir as flags, e janela máxima entre o primeiro
  /// e o último (como o "modo desenvolvedor" do Android).
  static const int _tapsToUnlock = 5;
  static const Duration _tapWindow = Duration(seconds: 3);

  String? _version;
  int _versionTaps = 0;
  DateTime? _firstTapAt;

  bool get _debugTools => widget.debugTools ?? debugToolsEnabled;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _version = '${info.version} (${info.buildNumber})');
    } catch (e) {
      // Sem plugin (testes) ou falha na plataforma: a linha fica sem número.
      log('AboutScreen: versão indisponível: $e');
    }
  }

  void _onVersionTap() {
    if (!_debugTools) return;
    final now = (widget.now ?? DateTime.now)();
    final first = _firstTapAt;
    if (first == null || now.difference(first) > _tapWindow) {
      _firstTapAt = now;
      _versionTaps = 0;
    }
    _versionTaps++;

    final remaining = _tapsToUnlock - _versionTaps;
    final messenger = ScaffoldMessenger.of(context);
    if (remaining <= 0) {
      _versionTaps = 0;
      _firstTapAt = null;
      messenger.hideCurrentSnackBar();
      context.push(debugFlagsPath);
    } else if (remaining <= 2) {
      // Só nos toques 3 e 4, discreto, como o Android faz.
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            key: const Key('about_debug_hint'),
            content: Text(
              remaining == 1 ? 'mais 1 toque…' : 'mais $remaining toques…',
            ),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
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
            // Balão de informação 3D; até carregar, o ícone preto sobre disco
            // amarelo (o amarelo é fundo, não traço) do mesmo tamanho.
            Center(
              child: BingoLavaIconView(
                key: const Key('about_hero_bubble'),
                icon: BingoLavaIcon.infoBubble,
                size: 72,
                fallback: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.outline, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.outline,
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    size: 40,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            _SectionTitle(
              icon: BingoLavaIcon.warning,
              iconKey: const Key('about_warning_icon'),
              fallbackIcon: Icons.warning_amber_rounded,
              text: l10n.aboutImportantTitle,
              style: textTheme.headlineSmall?.copyWith(
                color: AppColors.warningText,
                fontWeight: FontWeight.w700,
              ),
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

            _SectionTitle(
              icon: BingoLavaIcon.book,
              iconKey: const Key('about_book_icon'),
              fallbackIcon: Icons.menu_book_rounded,
              text: l10n.aboutHowToPlayTitle,
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildStep(context, '1', l10n.aboutStep1Title, l10n.aboutStep1Desc),
            _buildStep(context, '2', l10n.aboutStep2Title, l10n.aboutStep2Desc),
            _buildStep(context, '3', l10n.aboutStep3Title, l10n.aboutStep3Desc),
            _buildStep(context, '4', l10n.aboutStep4Title, l10n.aboutStep4Desc),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            _SectionTitle(
              icon: BingoLavaIcon.globe,
              iconKey: const Key('about_globe_icon'),
              fallbackIcon: Icons.language_rounded,
              text: l10n.aboutLanguage,
              style: textTheme.titleMedium,
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
                      child: Text('English (US)'),
                    ),
                    DropdownMenuItem(
                      value: 'pt',
                      child: Text('Português (BR)'),
                    ),
                    DropdownMenuItem(
                      value: 'es',
                      child: Text('Español (ES)'),
                    ),
                    DropdownMenuItem(
                      value: 'fr',
                      child: Text('Français (FR)'),
                    ),
                    DropdownMenuItem(
                      value: 'it',
                      child: Text('Italiano (IT)'),
                    ),
                    DropdownMenuItem(value: 'ja', child: Text('日本語 (JA)')),
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
            const SizedBox(height: 16),
            // Versão do app. Em dev/alpha, 5 toques aqui abrem /debug/flags;
            // em prod o toque não faz nada.
            InkWell(
              key: const Key('about_version_row'),
              onTap: _onVersionTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  l10n.aboutVersion(_version ?? '—'),
                  key: const Key('about_version_text'),
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
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

/// Título de seção com um ícone Lava em linha, à esquerda do texto (no lugar
/// dos emojis que abriam os títulos). O ícone Material fica até o bundle
/// carregar.
class _SectionTitle extends StatelessWidget {
  final BingoLavaIcon icon;
  final Key iconKey;
  final IconData fallbackIcon;
  final String text;
  final TextStyle? style;

  const _SectionTitle({
    required this.icon,
    required this.iconKey,
    required this.fallbackIcon,
    required this.text,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BingoLavaIconView(
          key: iconKey,
          icon: icon,
          size: 40,
          fallback: Icon(fallbackIcon, size: 28, color: AppColors.text),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: style)),
      ],
    );
  }
}
