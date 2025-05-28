import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:mawaqit/i18n/l10n.dart';
import 'package:sizer/sizer.dart';

class OnBoardingMawaqitAboutWidget extends StatefulWidget {
  const OnBoardingMawaqitAboutWidget({
    Key? key,
    this.onNext,
    this.nextButtonFocusNode = const fp.None(),
  }) : super(key: key);

  final VoidCallback? onNext;
  final fp.Option<FocusNode> nextButtonFocusNode;

  @override
  State<OnBoardingMawaqitAboutWidget> createState() => _OnBoardingMawaqitAboutWidgetState();
}

class _OnBoardingMawaqitAboutWidgetState extends State<OnBoardingMawaqitAboutWidget> {
  @override
  void initState() {
    super.initState();

    // Use a timeout to prevent indefinite focus issues
    final timeout = Future.delayed(Duration(seconds: 2), () {
      // No focus was requested within timeout, nothing to do
    });

    widget.nextButtonFocusNode.fold(
      () => null,
      (focusNode) {
        // Small delay to ensure the widget is fully built
        Future.delayed(Duration(milliseconds: 300), () {
          // Cancel timeout since we're handling it
          timeout.ignore();

          if (mounted && focusNode.canRequestFocus) {
            focusNode.requestFocus();
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Focus(
      autofocus: true,
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event.isKeyPressed(LogicalKeyboardKey.select) || event.isKeyPressed(LogicalKeyboardKey.enter)) {
          widget.onNext?.call();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Align(
        alignment: const Alignment(0, -.3),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S.of(context).mawaqitWelcome,
                style: TextStyle(
                  fontSize: isTablet ? 16.sp : 20.sp,
                  fontWeight: FontWeight.w700,
                  color: themeData.brightness == Brightness.dark ? Colors.white70 : themeData.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              Flexible(
                fit: FlexFit.tight,
                child: AutoSizeText(
                  S.of(context).mawaqitDesc,
                  stepGranularity: 1,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: isTablet ? 10.sp : 12.sp,
                    color: themeData.brightness == Brightness.dark ? Colors.white60 : themeData.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
