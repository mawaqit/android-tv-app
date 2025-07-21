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
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Focus(
      autofocus: true,
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event.isKeyPressed(LogicalKeyboardKey.select) || event.isKeyPressed(LogicalKeyboardKey.enter)) {
          widget.onNext?.call();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title section - flexible
          Text(
            S.of(context).mawaqitWelcome,
            style: TextStyle(
              fontSize: isTablet ? 16.sp : 20.sp,
              fontWeight: FontWeight.w700,
              color: themeData.brightness == Brightness.dark ? Colors.white70 : themeData.primaryColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),

          // Spacer
          SizedBox(height: isPortrait ? 1.h : 2.h),

          // Description section - expandable
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w),
              child: AutoSizeText(
                S.of(context).mawaqitDesc,
                textAlign: TextAlign.justify,
                minFontSize: 10,
                style: TextStyle(
                  fontSize: isTablet ? 12.sp : 14.sp,
                  height: 1.4,
                  color: themeData.brightness == Brightness.dark ? Colors.white60 : themeData.primaryColor,
                ),
              ),
            ),
          ),
          SizedBox(height: isPortrait ? 1.h : 2.h),
        ],
      ),
    );
  }
}
