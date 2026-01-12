import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

class FlippableCard extends StatelessWidget {
  final String image;
  final String text;

  const FlippableCard({super.key, required this.image, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FlipCard(
        front: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          child: Stack(
            children: [
              Image.asset(
                image,
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
    );
  }
}
