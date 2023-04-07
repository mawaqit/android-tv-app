import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// this widget is used to show a screen with a lottie animation on the left side
class ScreenWithAnimationWidget extends StatelessWidget {
  const ScreenWithAnimationWidget({
    Key? key,
    required this.animation,
    required this.child,
  }) : super(key: key);

  /// only the animation name without the extension
  final String animation;

  /// the widget to show on the right side
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
              child: Align(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Lottie.asset(
                    'assets/animations/lottie/$animation.json',
                    fit: BoxFit.contain,
                  ),
                ),
                alignment: Alignment.center,
              ),
            ),
            Expanded(flex: 6, child: child),
          ],
        ),
      ),
    );
  }
}
