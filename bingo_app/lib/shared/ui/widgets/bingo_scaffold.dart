import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:bingo_app/shared/ui/widgets/back_button.dart';
import 'package:bingo_app/shared/ui/widgets/stroked_text.dart';
import 'package:flutter/material.dart';

class BingoScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  /// Barra fixa no rodapé (ex.: botão principal sempre visível). O corpo
  /// encolhe para abrir espaço; respeite a área segura dentro dela.
  final Widget? bottomNavigationBar;

  const BingoScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.onBack,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: BingoBackButton(
          backgroundColor: AppColors.card,
          onPressed: onBack,
        ),
        title: StrokedText(text: title, style: textTheme.displaySmall),
        centerTitle: true,
        actions: actions,
      ),
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
