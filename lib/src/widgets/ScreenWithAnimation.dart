import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

/// this widget is used to show a screen with a lottie animation on the left side
class ScreenWithAnimationWidget extends StatelessWidget {
  const ScreenWithAnimationWidget({
    Key? key,
    required this.animation,
    required this.child,
    this.hasBackButton = false,
  }) : super(key: key);

  /// only the animation name without the extension
  final String animation;

  /// the widget to show on the right side
  final Widget child;
  final bool hasBackButton;

  @override
  Widget build(BuildContext context) {
    final userPrefs = context.watch<UserPreferencesManager>();

    return Scaffold(
      appBar: hasBackButton
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                // Set your desired size here
                iconSize: 12.sp,
                focusColor: Theme.of(context).focusColor,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            )
          : AppBar(
              scrolledUnderElevation: 0,
              elevation: 0,
            ),
      body: SafeArea(
        child: Flex(
          direction: userPrefs.calculatedOrientation == Orientation.portrait ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
              child: Align(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Lottie.asset(
                    animation.contains('assets/') ? animation : 'assets/animations/lottie/$animation.json',
                    fit: BoxFit.contain,
                  ),
                ),
                alignment: Alignment.center,
              ),
            ),
            Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: child,
                )),
          ],
        ),
      ),
    );
  }
}
