import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/services/sound_service.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_scaffold.dart';
import 'package:flutter/material.dart';

/// Preferências do app. Hoje só som; a tela já nasce seccionada para receber
/// vibração, idioma e o que mais vier sem virar uma lista solta.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return BingoScaffold(
      title: l10n.settingsTitle,
      body: ListView(
        key: const ValueKey<String>('settings_screen'),
        padding: const EdgeInsets.all(24.0),
        children: [
          _SectionTitle(
            icon: Icons.volume_up_rounded,
            text: l10n.settingsSoundSection,
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),

          // Liga/desliga geral. O volume abaixo fica inerte quando isto cai.
          ValueListenableBuilder<bool>(
            valueListenable: SoundService.enabled,
            builder: (context, enabled, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SwitchListTile(
                    key: const Key('settings_sound_switch'),
                    contentPadding: EdgeInsets.zero,
                    value: enabled,
                    title: Text(
                      l10n.settingsSoundEffects,
                      style: textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      l10n.settingsSoundEffectsSubtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    // Amarelo é preenchimento e o preto é contorno, como no
                    // resto do design system; sem isso o switch herdaria um
                    // amarelo sobre branco que não passa no contraste.
                    thumbColor: const WidgetStatePropertyAll<Color>(
                      AppColors.outline,
                    ),
                    trackColor: WidgetStateProperty.resolveWith<Color>(
                      (states) => states.contains(WidgetState.selected)
                          ? AppColors.primary
                          : AppColors.disabled,
                    ),
                    trackOutlineColor: const WidgetStatePropertyAll<Color>(
                      AppColors.outline,
                    ),
                    onChanged: (value) {
                      SoundService.setEnabled(value);
                      // Toca só ao ligar: confirma o que acabou de mudar.
                      if (value) SoundService.play(BingoSfx.mark);
                    },
                  ),
                  const SizedBox(height: 8),
                  _VolumeRow(enabled: enabled, label: l10n.settingsVolume),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      key: const Key('settings_sound_test'),
                      onPressed: enabled
                          ? () => SoundService.play(BingoSfx.draw)
                          : null,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(l10n.settingsVolumeTest),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          _SectionTitle(
            icon: Icons.copyright_rounded,
            text: l10n.settingsCreditsSection,
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.settingsAudioCredits,
            key: const Key('settings_audio_credits'),
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Slider de volume. Fora do [ValueListenableBuilder] do switch para que
/// arrastar não reconstrua a seção inteira.
class _VolumeRow extends StatelessWidget {
  const _VolumeRow({required this.enabled, required this.label});

  final bool enabled;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder<double>(
      valueListenable: SoundService.volume,
      builder: (context, volume, _) {
        return Row(
          children: [
            Text(
              label,
              style: textTheme.titleMedium?.copyWith(
                color: enabled ? AppColors.text : AppColors.disabled,
              ),
            ),
            Expanded(
              child: Slider(
                key: const Key('settings_volume_slider'),
                value: volume,
                divisions: 10,
                label: '${(volume * 100).round()}%',
                activeColor: AppColors.primary,
                inactiveColor: AppColors.disabled,
                thumbColor: AppColors.outline,
                semanticFormatterCallback: (value) =>
                    '$label ${(value * 100).round()}%',
                onChanged: enabled
                    ? (value) => SoundService.setVolume(value)
                    : null,
                // Prévia só ao soltar: tocar a cada passo do arrasto vira
                // metralhadora de bipes.
                onChangeEnd: enabled
                    ? (_) => SoundService.play(BingoSfx.mark)
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Cabeçalho de seção: disco amarelo com contorno preto e o rótulo ao lado,
/// no mesmo desenho das demais telas.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.text,
    required this.style,
  });

  final IconData icon;
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.outline, width: 2),
          ),
          child: Icon(icon, size: 20, color: AppColors.text),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: style)),
      ],
    );
  }
}
