import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../themes/beer_colors.dart';

class BeerBubbleDecoration extends StatelessWidget {
  final bool enableAnimation;
  final double animationDuration;

  const BeerBubbleDecoration({
    super.key,
    this.enableAnimation = false,
    this.animationDuration = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 右上角大泡泡群
        _buildBubbleGroup([
          _BubbleData(
            top: 30.h,
            right: -40.w,
            size: 150.w,
            gradient: RadialGradient(
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.05),
              ],
            ),
          ),
          _BubbleData(
            top: 70.h,
            right: 20.w,
            size: 80.w,
            gradient: RadialGradient(
              colors: [
                BeerColors.yellow300.withOpacity(0.4),
                BeerColors.yellow300.withOpacity(0.08),
              ],
            ),
          ),
          _BubbleData(
            top: 120.h,
            right: 60.w,
            size: 45.w,
            color: Colors.white.withOpacity(0.25),
          ),
        ]),

        // 中間區域的泡泡
        _buildBubbleGroup([
          _BubbleData(
            top: 200.h,
            left: 20.w,
            size: 35.w,
            gradient: RadialGradient(
              colors: [
                BeerColors.primaryAmber200.withOpacity(0.5),
                BeerColors.primaryAmber200.withOpacity(0.1),
              ],
            ),
          ),
          _BubbleData(
            top: 300.h,
            right: 15.w,
            size: 25.w,
            color: Colors.white.withOpacity(0.3),
          ),
        ]),

        // 左下角大泡泡群
        _buildBubbleGroup([
          _BubbleData(
            bottom: 80.h,
            left: -50.w,
            size: 140.w,
            gradient: RadialGradient(
              colors: [
                BeerColors.orange300.withOpacity(0.3),
                BeerColors.orange300.withOpacity(0.05),
              ],
            ),
          ),
          _BubbleData(
            bottom: 120.h,
            left: 30.w,
            size: 60.w,
            gradient: RadialGradient(
              colors: [
                Colors.white.withOpacity(0.35),
                Colors.white.withOpacity(0.08),
              ],
            ),
          ),
          _BubbleData(
            bottom: 180.h,
            left: 70.w,
            size: 30.w,
            color: BeerColors.yellow200.withOpacity(0.4),
          ),
        ]),

        // 額外的小泡泡增加層次感
        _buildBubbleGroup([
          _BubbleData(
            top: 250.h,
            left: 80.w,
            size: 20.w,
            color: Colors.white.withOpacity(0.35),
          ),
          _BubbleData(
            bottom: 250.h,
            right: 40.w,
            size: 35.w,
            gradient: RadialGradient(
              colors: [
                BeerColors.primaryAmber300.withOpacity(0.4),
                BeerColors.primaryAmber300.withOpacity(0.1),
              ],
            ),
          ),
          _BubbleData(
            bottom: 320.h,
            left: 15.w,
            size: 25.w,
            color: Colors.white.withOpacity(0.3),
          ),
        ]),
      ],
    );
  }

  Widget _buildBubbleGroup(List<_BubbleData> bubbles) {
    return Stack(
      children: bubbles.map((bubble) => _buildBubble(bubble)).toList(),
    );
  }

  Widget _buildBubble(_BubbleData bubble) {
    Widget bubbleWidget = Container(
      width: bubble.size,
      height: bubble.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bubble.color,
        gradient: bubble.gradient,
      ),
    );

    return Positioned(
      top: bubble.top,
      bottom: bubble.bottom,
      left: bubble.left,
      right: bubble.right,
      child: enableAnimation
          ? _AnimatedBubble(
              duration: animationDuration,
              child: bubbleWidget,
            )
          : bubbleWidget,
    );
  }
}

class _BubbleData {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;
  final Color? color;
  final Gradient? gradient;

  _BubbleData({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    this.color,
    this.gradient,
  });
}

class _AnimatedBubble extends StatefulWidget {
  final Widget child;
  final double duration;

  const _AnimatedBubble({
    required this.child,
    required this.duration,
  });

  @override
  State<_AnimatedBubble> createState() => _AnimatedBubbleState();
}

class _AnimatedBubbleState extends State<_AnimatedBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: widget.duration.toInt()),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}