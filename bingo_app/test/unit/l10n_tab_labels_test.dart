import 'package:bingo_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'rótulos das abas da sala têm no máximo 12 caracteres em todo idioma',
    () async {
      for (final locale in AppLocalizations.supportedLocales) {
        final l10n = await AppLocalizations.delegate.load(locale);
        for (final label in [l10n.virtualGlobe, l10n.manualGlobe]) {
          expect(
            label.characters.length,
            lessThanOrEqualTo(12),
            reason: '"$label" (${locale.languageCode}) é longo para a aba',
          );
        }
      }
    },
  );

  test(
    'rótulo "digitar código" cabe em uma linha (<= 20 caracteres)',
    () async {
      for (final locale in AppLocalizations.supportedLocales) {
        final l10n = await AppLocalizations.delegate.load(locale);
        expect(
          l10n.scanManualButton.characters.length,
          lessThanOrEqualTo(20),
          reason:
              '"${l10n.scanManualButton}" (${locale.languageCode}) quebraria '
              'em duas linhas no botão',
        );
      }
    },
  );
}
