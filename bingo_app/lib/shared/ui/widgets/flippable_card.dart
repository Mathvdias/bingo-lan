import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

/// Cartão que vira ao toque: frente com uma imagem ([image]) ou um widget
/// ([hero], por exemplo um ícone Lava), verso com [text].
class FlippableCard extends StatelessWidget {
  final String? image;
  final Widget? hero;
  final String text;

  const FlippableCard({
    super.key,
    this.image,
    this.hero,
    required this.text,
  }) : assert(image != null || hero != null, 'image ou hero');

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: 300,
        child: FlipCard(
          front: Card(
            clipBehavior: Clip.antiAlias,
            elevation: 4.0,
            child: Stack(
              children: [
                if (hero != null)
                  SizedBox.expand(child: Center(child: hero))
                else
                  Image.asset(
                    image!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.info_outline),
                ),
              ],
            ),
          ),
          back: Card(
            elevation: 4.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(text, textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
    );
  }
}
