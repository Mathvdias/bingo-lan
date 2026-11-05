import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:google_fonts/google_fonts.dart';

import 'tokens/app_colors.dart';

/// Barras do sistema transparentes com ícones escuros: o conteúdo corre de
/// ponta a ponta por baixo delas (edge-to-edge).
///
/// Precisa estar também no `appBarTheme`. O AppBar reaplica o próprio
/// `systemOverlayStyle` sempre que entra em tela, e o padrão
/// [SystemUiOverlayStyle.dark] traz `systemNavigationBarColor` preto com
/// ícones claros — uma faixa preta no rodapé de um app creme, por cima do que
/// o `main` tiver configurado.
///
/// `systemNavigationBarContrastEnforced: false` evita que o Android pinte um
/// véu translúcido atrás da barra para "garantir contraste".
const SystemUiOverlayStyle kBingoSystemUiStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
  systemNavigationBarColor: Colors.transparent,
  systemNavigationBarDividerColor: Colors.transparent,
  systemNavigationBarIconBrightness: Brightness.dark,
  systemNavigationBarContrastEnforced: false,
);

/// Fábrica de [TextStyle] para uma família (display ou corpo).
///
/// Compatível com `GoogleFonts.fredoka` / `GoogleFonts.inter`; os testes
/// passam uma fábrica sem rede para não dependerem do download das fontes.
typedef BingoFontBuilder =
    TextStyle Function({
      double? fontSize,
      FontWeight? fontWeight,
      double? height,
    });

/// Tema do app. Toda cor de texto/fundo é decidida aqui para que a regra
/// "amarelo é preenchimento, nunca texto" não regrida tela a tela.
///
/// [display] e [body] trocam as famílias (padrão: Fredoka e Inter via
/// google_fonts).
ThemeData buildBingoTheme({BingoFontBuilder? display, BingoFontBuilder? body}) {
  final BingoFontBuilder d = display ?? GoogleFonts.fredoka;
  final BingoFontBuilder b = body ?? GoogleFonts.inter;

  final roundedOutline = RoundedRectangleBorder(
    side: const BorderSide(color: AppColors.outline, width: 2),
    borderRadius: BorderRadius.circular(16),
  );
  final buttonLabel = d(fontSize: 18, fontWeight: FontWeight.w700);
  final textButtonLabel = b(fontSize: 14, fontWeight: FontWeight.w700);

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.surface,
    fontFamily: b().fontFamily, // Default body font
    // Color Scheme: pastéis como fundo, preto como texto sobre eles.
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.text,
      surface: AppColors.card,
      onSurface: AppColors.text,
      onSurfaceVariant: AppColors.textSecondary,
      error: AppColors.error,
      onError: AppColors.text,
      outline: AppColors.outline,
    ),

    // Default AppBar style
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: kBingoSystemUiStyle,
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: d(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ), // H1
      displayMedium: d(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ), // H2
      displaySmall: d(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ), // H3
      bodyLarge: b(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 1.5,
      ), // Body
      bodyMedium: b(fontSize: 14, fontWeight: FontWeight.normal, height: 1.5),
      // Special style for the big drawn number
      headlineLarge: d(fontSize: 120, fontWeight: FontWeight.bold, height: 1.0),
      headlineMedium: d(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        height: 1.0,
      ), // Number
    ),

    // Default InputDecoration style
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.outline, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.outline, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.outline, width: 4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.errorText, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.errorText, width: 4),
      ),
      // Erro como texto sobre fundo claro usa o token de contraste.
      errorStyle: b(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ).copyWith(color: AppColors.errorText),
    ),

    // Botões: amarelo de fundo + texto preto + contorno. Nunca texto amarelo.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.text,
        disabledBackgroundColor: AppColors.disabled,
        disabledForegroundColor: AppColors.text,
        elevation: 0,
        side: const BorderSide(color: AppColors.outline, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: buttonLabel,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.text,
        disabledBackgroundColor: AppColors.disabled,
        disabledForegroundColor: AppColors.text,
        elevation: 0,
        side: const BorderSide(color: AppColors.outline, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: buttonLabel,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.text,
        disabledForegroundColor: AppColors.textSecondary,
        side: const BorderSide(color: AppColors.outline, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: buttonLabel,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.text,
        disabledForegroundColor: AppColors.textSecondary,
        minimumSize: const Size(48, 48),
        textStyle: textButtonLabel,
      ),
    ),

    // Default SegmentedButton style
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: AppColors.primary,
        selectedForegroundColor: AppColors.text,
        foregroundColor: AppColors.text,
        side: const BorderSide(color: AppColors.outline, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: b(fontSize: 14, fontWeight: FontWeight.normal),
      ),
    ),

    // Default Card style
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: roundedOutline,
    ),

    // Diálogos: branco, contorno preto, texto preto.
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.card,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: roundedOutline,
      titleTextStyle: d(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ).copyWith(color: AppColors.text),
      contentTextStyle: b(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 1.5,
      ).copyWith(color: AppColors.text),
    ),

    // Abas: rótulo preto, inativo cinza, indicador amarelo grosso (é
    // preenchimento, não texto).
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.text,
      unselectedLabelColor: AppColors.textSecondary,
      labelStyle: b(fontSize: 14, fontWeight: FontWeight.w700),
      unselectedLabelStyle: b(fontSize: 14, fontWeight: FontWeight.w600),
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.primary, width: 4),
      ),
      dividerColor: AppColors.outline,
      dividerHeight: 2,
      overlayColor: WidgetStatePropertyAll(
        AppColors.primary.withValues(alpha: 0.2),
      ),
    ),

    // Toasts: cartão branco com contorno; a cor de fundo pode ser trocada
    // por um pastel (erro/sucesso) e o texto continua preto.
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.card,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      contentTextStyle: b(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ).copyWith(color: AppColors.text),
      actionTextColor: AppColors.accentText,
      closeIconColor: AppColors.text,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.outline, width: 2),
      ),
    ),

    // Chips (selo PREMIUM): amarelo de fundo, texto preto, contorno.
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.primary,
      labelStyle: b(
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ).copyWith(color: AppColors.text),
      side: const BorderSide(color: AppColors.outline, width: 2),
      shape: const StadiumBorder(),
      iconTheme: const IconThemeData(color: AppColors.text, size: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    ),

    iconTheme: const IconThemeData(color: AppColors.text),
    dividerTheme: const DividerThemeData(
      color: AppColors.outline,
      thickness: 1,
    ),
    tooltipTheme: TooltipThemeData(
      textStyle: b(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ).copyWith(color: AppColors.card),
      decoration: BoxDecoration(
        color: AppColors.outline,
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

/// The main theme data for the Bingo App.
final ThemeData bingoTheme = buildBingoTheme();
