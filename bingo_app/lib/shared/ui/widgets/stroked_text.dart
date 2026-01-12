import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:flutter/material.dart';

class StrokedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double strokeWidth;
  final Color strokeColor;
  final Color fillColor;

  const StrokedText({
    super.key,
    required this.text,
    this.style,
    this.strokeWidth = 4.0,
    this.strokeColor = AppColors.outline,
    this.fillColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final effectiveTextStyle = style ?? textTheme.bodyLarge;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Border text
        Text(
          text,
          textAlign: TextAlign.center,
          style: effectiveTextStyle?.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ),
        ),
        // Fill text
        Text(
          text,
          textAlign: TextAlign.center,
          style: effectiveTextStyle?.copyWith(
            color: fillColor,
          ),
        ),
      ],
    );
  }
}
