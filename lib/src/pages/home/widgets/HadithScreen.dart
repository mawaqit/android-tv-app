import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/StringUtils.dart';
import 'package:mawaqit/src/helpers/repaint_boundaries.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';

/// this screen made to show of the hadith screen
class HadithWidget extends StatelessWidget {
  const HadithWidget({
    Key? key,
    this.title,
    this.arabicText,
    this.translatedTitle,
    this.translatedText,
    this.textDirection,
  }) : super(key: key);

  /// The main title of the screen
  final String? title;

  /// arabic text of the hadith screen
  final String? arabicText;

  /// translated title of the hadith
  final String? translatedTitle;

  /// translated text of the hadith
  final String? translatedText;

  /// force the text direction of the translated text
  /// used for random hadith because hadith language is not the same as the app language
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (title != null)
          titleText(
            title!,
            textDirection: TextDirection.rtl,
          ),
        if (arabicText != null)
          contentText(
            arabicText!,
            textDirection: TextDirection.rtl,
            delay: .1.seconds,
          ),
        if (translatedTitle != null && translatedTitle != title)
          titleText(
            translatedTitle!,
            textDirection: textDirection,
            delay: .2.seconds,
          ),
        if (translatedText != null && translatedText != arabicText)
          contentText(
            translatedText!,
            textDirection: textDirection,
            delay: .3.seconds,
          ),
      ],
    );
  }

  Widget titleText(
    String text, {
    TextDirection? textDirection,
    Duration? delay,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 6.2.vw,
        fontWeight: FontWeight.bold,
        fontFamily: StringManager.getFontFamilyByString(text),
        color: Colors.white,
        shadows: kAfterAdhanTextShadow,
      ),
      textAlign: TextAlign.center,
      textDirection: textDirection,
    ).animate(delay: delay).slide().fade().addRepaintBoundary();
  }

  Widget contentText(
    String text, {
    TextDirection? textDirection,
    Duration? delay,
  }) {
    return Flexible(
      fit: FlexFit.loose,
      child: Padding(
        key: ValueKey(text),
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: AutoSizeText(
          text,
          style: TextStyle(
            fontSize: 6.2.vw,
            fontFamily: StringManager.getFontFamilyByString(text),
            color: Colors.white,
            shadows: kIqamaCountDownTextShadow,
          ),
          textAlign: TextAlign.center,
          textDirection: textDirection,
        ).animate().fadeIn(delay: delay).addRepaintBoundary(),
      ),
    );
  }
}
