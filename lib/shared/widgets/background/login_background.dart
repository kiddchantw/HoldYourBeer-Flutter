import 'package:flutter/material.dart';
import 'beer_gradient_background.dart';
import 'beer_bubble_decoration.dart';

class LoginBackground extends StatelessWidget {
  final Widget child;
  final bool enableBubbleAnimation;
  final double bubbleAnimationDuration;
  final List<Color>? customGradientColors;

  const LoginBackground({
    super.key,
    required this.child,
    this.enableBubbleAnimation = false,
    this.bubbleAnimationDuration = 3.0,
    this.customGradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return BeerGradientBackground(
      customColors: customGradientColors,
      child: Stack(
        children: [
          // 泡泡裝飾效果
          BeerBubbleDecoration(
            enableAnimation: enableBubbleAnimation,
            animationDuration: bubbleAnimationDuration,
          ),
          // 主要內容
          child,
        ],
      ),
    );
  }
}