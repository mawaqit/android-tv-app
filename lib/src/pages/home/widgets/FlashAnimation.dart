import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

extension FlashAnimationExtension on Widget {
  Widget flashAnimation() {
    return FlashAnimation(child: this);
  }
}

class FlashAnimation extends StatelessWidget {
  final Widget child;

  const FlashAnimation({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Animate(
        onPlay: (controller) {
          controller.repeat(reverse: true);
        },
        effects: [FadeEffect(curve: Curves.fastLinearToSlowEaseIn, delay: 1.seconds, begin: 1, end: 0)],
        child: child,
      ),
    );
  }
}
