import 'package:bingo_app/shared/ui/app_theme.dart';
import 'package:flutter/material.dart';

TextStyle _plainFont({
  double? fontSize,
  FontWeight? fontWeight,
  double? height,
}) {
  return TextStyle(fontSize: fontSize, fontWeight: fontWeight, height: height);
}

/// O tema real do app com a fonte padrão do sistema no lugar do google_fonts
/// (que tentaria baixar Fredoka/Inter durante o teste).
final ThemeData testBingoTheme = buildBingoTheme(
  display: _plainFont,
  body: _plainFont,
);
