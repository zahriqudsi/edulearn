import 'package:flutter/material.dart';
import 'package:edulearn/core/constants/app_colors.dart';

class AppLoader extends StatefulWidget {
  final Color? color;
  final double size;
  final double dotSize;

  const AppLoader({
    super.key,
    this.color,
    this.size = 24,
    this.dotSize = 6,
  });

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.color ?? AppColors.accent;

    return SizedBox(
      width: widget.size * 2,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index * 0.2;
              double progress = (_controller.value - delay) % 1.0;
              if (progress < 0) progress += 1.0;

              double opacity = 0.3;
              double scale = 0.8;

              if (progress < 0.4) {
                // Rising
                double t = progress / 0.4;
                opacity = 0.3 + (0.7 * t);
                scale = 0.8 + (0.4 * t);
              } else if (progress < 0.8) {
                // Falling
                double t = (progress - 0.4) / 0.4;
                opacity = 1.0 - (0.7 * t);
                scale = 1.2 - (0.4 * t);
              }

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: widget.dotSize * scale,
                width: widget.dotSize * scale,
                decoration: BoxDecoration(
                  color: activeColor.withOpacity(opacity.clamp(0.0, 1.0)),
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (opacity > 0.8)
                      BoxShadow(
                        color: activeColor.withOpacity(0.2),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
