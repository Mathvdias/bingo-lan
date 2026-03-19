import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../tokens/app_colors.dart';

class BingoBall extends StatelessWidget {
  final int number;
  final bool isDrawn;
  final double size;

  const BingoBall({
    super.key,
    required this.number,
    this.isDrawn = false,
    this.size = 60.0,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
      color: isDrawn ? Colors.white : AppColors.outline,
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDrawn ? AppColors.success : AppColors.card,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.outline, width: 2),
      ),
      child: Center(child: Text(number.toString(), style: textStyle)),
    );
  }
}

@Preview(name: 'Bingo Ball - Normal')
Widget bingoBallNormalPreview() => const Scaffold(body: Center(child: BingoBall(number: 75)));

@Preview(name: 'Bingo Ball - Drawn')
Widget bingoBallDrawnPreview() => const Scaffold(body: Center(child: BingoBall(number: 75, isDrawn: true)));
