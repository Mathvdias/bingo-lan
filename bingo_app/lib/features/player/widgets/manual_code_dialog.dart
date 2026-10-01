import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:bingo_app/shared/ui/widgets/bingo_button.dart';
import 'package:flutter/material.dart';

/// Abre o diálogo de código manual e devolve o código digitado (sem espaços
/// nas pontas) ou `null` se o jogador cancelou ou deixou vazio.
Future<String?> showManualCodeDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => const ManualCodeDialog(),
  );
}

/// Diálogo "Digitar código": o [TextEditingController] vive no estado, criado
/// uma única vez. Recriar o controller a cada build (como era feito) movia o
/// cursor para o início e embaralhava texto digitado em rajada.
class ManualCodeDialog extends StatefulWidget {
  const ManualCodeDialog({super.key});

  @override
  State<ManualCodeDialog> createState() => _ManualCodeDialogState();
}

class _ManualCodeDialogState extends State<ManualCodeDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.scanManualTitle),
      // Rolável: com o teclado aberto em tela de 640 dp o conteúdo não cabe.
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.scanManualHint),
            const SizedBox(height: 16),
            TextField(
              key: const Key('manual_code_field'),
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.inviteRoomCode,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              minLines: 1,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('manual_code_cancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.scanCancel),
        ),
        BingoButton(
          key: const Key('manual_code_join'),
          label: l10n.scanJoin,
          onPressed: _submit,
        ),
      ],
    );
  }
}
