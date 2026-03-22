import 'dart:developer';

import 'package:google_fonts/google_fonts.dart';

/// Pré-carrega as famílias usadas em [bingoTheme] para reduzir troca de fonte no primeiro frame.
Future<void> preloadBingoFonts() async {
  try {
    await GoogleFonts.pendingFonts([
      GoogleFonts.inter(),
      GoogleFonts.fredoka(),
    ]);
  } catch (e) {
    log('Font preload skipped: $e');
  }
}
