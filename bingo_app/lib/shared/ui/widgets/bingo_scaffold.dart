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
  /// encolhe para abrir espaço.
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
      // O app é edge-to-edge: sem isto o rodapé do conteúdo fica debaixo da
      // barra de navegação — bem visível com os três botões virtuais, que
      // ocupam mais altura que a barrinha de gesto. O AppBar já cuida do
      // topo sozinho, por isso `top: false`.
      //
      // Quando há barra no rodapé é ela que encosta no recorte, não o corpo.
      body: SafeArea(
        top: false,
        bottom: bottomNavigationBar == null,
        child: body,
      ),
      bottomNavigationBar: bottomNavigationBar == null
          ? null
          : SafeArea(top: false, child: bottomNavigationBar!),
    );
  }
}
