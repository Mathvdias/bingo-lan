import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

Color? _renderedColor(WidgetTester tester, String text) {
  final paragraph = tester.renderObject<RenderParagraph>(find.text(text));
  return paragraph.text.style?.color;
}

void main() {
  testWidgets('AlertDialog herda cartão branco, contorno e texto preto', (
    tester,
  ) async {
    await pumpApp(
      tester,
      Center(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Encerrar Sala'),
                content: const Text('Tem certeza?'),
                actions: [
                  TextButton(onPressed: () {}, child: const Text('Não')),
                  TextButton(onPressed: () {}, child: const Text('Sim')),
                ],
              ),
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    final dialogMaterial = tester.widget<Material>(
      find
          .descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(dialogMaterial.color, AppColors.card);
    final shape = dialogMaterial.shape as RoundedRectangleBorder;
    expect(shape.side.color, AppColors.outline);
    expect(shape.side.width, 2);

    // Título, conteúdo e ações renderizados em preto: nada amarelo ou rosa
    // como texto sobre o branco.
    expect(_renderedColor(tester, 'Encerrar Sala'), AppColors.text);
    expect(_renderedColor(tester, 'Tem certeza?'), AppColors.text);
    expect(_renderedColor(tester, 'Sim'), AppColors.text);
    expect(_renderedColor(tester, 'Não'), AppColors.text);
  });
}
