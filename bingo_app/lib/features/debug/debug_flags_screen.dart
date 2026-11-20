import 'package:bingo_app/features/debug/feature_flag_catalog.dart';
import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_scaffold.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

/// Tela de depuração `/debug/flags` (só dev/alpha): lista o
/// [featureFlagCatalog] com valor efetivo, origem (remoto ou override) e um
/// controle por tipo. Mudanças valem na hora, sem reiniciar, e ficam salvas.
///
/// Textos em português e sem l10n de propósito: é ferramenta interna.
class DebugFlagsScreen extends StatefulWidget {
  /// Driver a usar; por padrão o [OverridableConfigDriver] do GetIt.
  final OverridableConfigDriver? driver;

  const DebugFlagsScreen({super.key, this.driver});

  @override
  State<DebugFlagsScreen> createState() => _DebugFlagsScreenState();
}

class _DebugFlagsScreenState extends State<DebugFlagsScreen> {
  late final OverridableConfigDriver _driver =
      widget.driver ?? GetIt.I<OverridableConfigDriver>();
  bool _fetching = false;

  Future<void> _refetch() async {
    setState(() => _fetching = true);
    try {
      await _driver.fetchAndActivate();
    } finally {
      if (mounted) setState(() => _fetching = false);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Remote Config buscado de novo.')),
    );
  }

  Future<void> _clearAll() async {
    await _driver.clearAll();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Overrides limpos.')));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BingoScaffold(
      title: 'Flags',
      body: ListenableBuilder(
        listenable: _driver,
        builder: (context, _) {
          final overrideCount = _driver.overrides.length;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Text(
                overrideCount == 0
                    ? 'Nenhum override local. Os valores vêm do Remote '
                          'Config (ou do default).'
                    : '$overrideCount override(s) local(is) ativo(s). Valem '
                          'só neste aparelho e sobrevivem ao reinício.',
                key: const Key('debug_flags_summary'),
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              for (final flag in featureFlagCatalog) ...[
                _FlagTile(flag: flag, driver: _driver),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: BingoButton(
                  key: const Key('debug_flags_clear_all'),
                  label: 'Limpar overrides',
                  color: AppColors.card,
                  onPressed: _clearAll,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BingoButton(
                  key: const Key('debug_flags_refetch'),
                  label: _fetching ? 'Buscando…' : 'Buscar remoto',
                  enabled: !_fetching,
                  onPressed: _refetch,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cartão de uma flag: nome, descrição, origem e controle.
class _FlagTile extends StatelessWidget {
  final FeatureFlag flag;
  final OverridableConfigDriver driver;

  const _FlagTile({required this.flag, required this.driver});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final overridden = driver.hasOverride(flag.key);
    final effective = driver.effective(flag.key, flag.type);

    return Container(
      key: Key('flag_tile_${flag.key}'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // Fundo amarelo claro marca visualmente quem tem override.
        color: overridden ? AppColors.pastelYellow : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outline,
          width: overridden ? 2.5 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  flag.key,
                  style: textTheme.titleMedium?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _SourceChip(
                key: Key('flag_source_${flag.key}'),
                overridden: overridden,
              ),
              if (overridden)
                IconButton(
                  key: Key('flag_clear_${flag.key}'),
                  tooltip: 'Voltar ao remoto',
                  icon: const Icon(Icons.restart_alt),
                  onPressed: () => driver.clearOverride(flag.key),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            flag.description,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Efetivo: $effective',
                  key: Key('flag_value_${flag.key}'),
                  style: textTheme.bodyMedium,
                ),
              ),
              _FlagControl(flag: flag, driver: driver, effective: effective),
            ],
          ),
        ],
      ),
    );
  }
}

class _SourceChip extends StatelessWidget {
  final bool overridden;

  const _SourceChip({super.key, required this.overridden});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: overridden ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.outline, width: 1.5),
      ),
      child: Text(
        overridden ? 'override' : 'remoto',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.text,
        ),
      ),
    );
  }
}

/// Controle por tipo: Switch (bool), stepper (int), dropdown ou campo
/// (string).
class _FlagControl extends StatelessWidget {
  final FeatureFlag flag;
  final OverridableConfigDriver driver;
  final Object effective;

  const _FlagControl({
    required this.flag,
    required this.driver,
    required this.effective,
  });

  @override
  Widget build(BuildContext context) {
    switch (flag.type) {
      case ConfigValueType.boolean:
        return Switch(
          key: Key('flag_switch_${flag.key}'),
          value: effective as bool,
          onChanged: (value) => driver.setOverride(flag.key, value),
        );
      case ConfigValueType.integer:
        final value = effective as int;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: Key('flag_int_minus_${flag.key}'),
              tooltip: 'Diminuir',
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: value > 0
                  ? () => driver.setOverride(flag.key, value - 1)
                  : null,
            ),
            SizedBox(
              width: 56,
              child: _IntField(
                key: Key('flag_int_field_${flag.key}'),
                value: value,
                onSubmitted: (v) => driver.setOverride(flag.key, v),
              ),
            ),
            IconButton(
              key: Key('flag_int_plus_${flag.key}'),
              tooltip: 'Aumentar',
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => driver.setOverride(flag.key, value + 1),
            ),
          ],
        );
      case ConfigValueType.string:
        final value = effective as String;
        if (flag.options.isNotEmpty) {
          final options = [
            ...flag.options,
            if (!flag.options.contains(value)) value,
          ];
          return DropdownButton<String>(
            key: Key('flag_dropdown_${flag.key}'),
            value: value,
            items: [
              for (final option in options)
                DropdownMenuItem(
                  value: option,
                  child: Text(option.isEmpty ? '(vazio)' : option),
                ),
            ],
            onChanged: (selected) {
              if (selected != null) driver.setOverride(flag.key, selected);
            },
          );
        }
        return SizedBox(
          width: 140,
          child: _StringField(
            key: Key('flag_text_${flag.key}'),
            value: value,
            onSubmitted: (v) => driver.setOverride(flag.key, v),
          ),
        );
    }
  }
}

/// Campo numérico que grava ao confirmar no teclado. Re-sincroniza com o
/// valor efetivo quando ele muda por fora (stepper, limpar).
class _IntField extends StatefulWidget {
  final int value;
  final ValueChanged<int> onSubmitted;

  const _IntField({super.key, required this.value, required this.onSubmitted});

  @override
  State<_IntField> createState() => _IntFieldState();
}

class _IntFieldState extends State<_IntField> {
  late final TextEditingController _controller = TextEditingController(
    text: '${widget.value}',
  );

  @override
  void didUpdateWidget(covariant _IntField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value &&
        _controller.text != '${widget.value}') {
      _controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        border: OutlineInputBorder(),
      ),
      onSubmitted: (text) {
        final parsed = int.tryParse(text);
        if (parsed != null) widget.onSubmitted(parsed);
      },
    );
  }
}

/// Campo de texto que grava ao confirmar no teclado.
class _StringField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onSubmitted;

  const _StringField({
    super.key,
    required this.value,
    required this.onSubmitted,
  });

  @override
  State<_StringField> createState() => _StringFieldState();
}

class _StringFieldState extends State<_StringField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );

  @override
  void didUpdateWidget(covariant _StringField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
        isDense: true,
        hintText: 'valor',
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(),
      ),
      onSubmitted: widget.onSubmitted,
    );
  }
}
