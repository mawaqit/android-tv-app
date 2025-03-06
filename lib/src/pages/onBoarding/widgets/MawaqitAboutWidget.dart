import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:mawaqit/i18n/l10n.dart';

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
    widget.nextButtonFocusNode.fold(
      () => null,
      (focusNode) => focusNode.requestFocus(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Focus(
      autofocus: true,
      onKey: (FocusNode node, RawKeyEvent event) {
        print(event.logicalKey);

        if (event.isKeyPressed(LogicalKeyboardKey.select) || event.isKeyPressed(LogicalKeyboardKey.enter)) {
          widget.onNext?.call();
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: Align(
        alignment: Alignment(0, -.3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              S.of(context).mawaqitWelcome,
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.w700,
                color: themeData.brightness == Brightness.dark ? Colors.white70 : themeData.primaryColor,
              ),
            ),
            SizedBox(height: 10),
            Flexible(
              fit: FlexFit.loose,
              child: AutoSizeText(
                S.of(context).mawaqitDesc,
                stepGranularity: 1,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 19,
                  color: themeData.brightness == Brightness.dark ? Colors.white60 : themeData.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
