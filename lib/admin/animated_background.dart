import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // مهم للويب

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Color?> colorA;
  late Animation<Color?> colorB;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    // تشغيل الـ animation بشكل آمن للويب
    controller.repeat(reverse: true);

    colorA = ColorTween(
      begin: const Color(0xFFF3EDE3),
      end: const Color(0xFFEEE6D6),
    ).animate(controller);

    colorB = ColorTween(
      begin: const Color(0xFFE9DDC9),
      end: const Color(0xFFF7F3EB),
    ).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose(); // مهم كي لا يحصل Memory leak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // حماية من بناء الخلفية قبل اكتمال الـ animation
    if (colorA.value == null || colorB.value == null) {
      return Container(
        color: const Color(0xFFF3EDE3),
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorA.value ?? const Color(0xFFF3EDE3),
                colorB.value ?? const Color(0xFFE9DDC9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
