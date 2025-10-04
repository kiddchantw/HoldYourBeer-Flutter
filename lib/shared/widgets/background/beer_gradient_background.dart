import 'package:flutter/material.dart';
import '../../themes/beer_colors.dart';

class BeerGradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? customColors;
  final Alignment? begin;
  final Alignment? end;

  const BeerGradientBackground({
    super.key,
    required this.child,
    this.customColors,
    this.begin,
    this.end,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin ?? Alignment.topCenter,
          end: end ?? Alignment.bottomCenter,
          colors: customColors ?? const [
            BeerColors.primaryAmber200,
            BeerColors.primaryAmber100,
            Color(0xFFFFF8E1), // 淺啤酒色
          ],
        ),
      ),
      child: child,
    );
  }
}