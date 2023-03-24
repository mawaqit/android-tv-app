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
  }) : super(key: key);

  final String? title;
  final String? arabicText;
  final String? translatedTitle;
  final String? translatedText;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (title != null)
          Text(
            title!,
            style: TextStyle(
                fontSize: 6.2.vw,
                fontWeight: FontWeight.bold,
                fontFamily:
                    StringManager.getFontFamilyByString(title!),
                color: Colors.white,
                shadows: kAfterAdhanTextShadow),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ).animate().slide().fade().addRepaintBoundary(),
        if (arabicText != null)
          Flexible(
            fit: FlexFit.loose,
            child: AutoSizeText(
              arabicText!,
              style: TextStyle(
                fontSize: 6.2.vw,
                fontWeight: FontWeight.bold,
                fontFamily: StringManager.getFontFamilyByString(arabicText!),
                color: Colors.white,
                shadows: kIqamaCountDownTextShadow,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: .3.seconds).addRepaintBoundary(),
          ),
        if (translatedTitle != null && translatedTitle != title)
          Text(
            translatedTitle!,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  shadows: kAfterAdhanTextShadow,
                  fontFamily: StringManager.getFontFamilyByString(
                    translatedTitle!,
                  ),
                ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ).animate().slideY(begin: 1).fade().addRepaintBoundary(),
        if (translatedText != null && translatedText != arabicText)
          Flexible(
            fit: FlexFit.loose,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: AutoSizeText(
                stepGranularity: 1,
                translatedText!,
                style: TextStyle(
                  fontSize: 6.2.vw,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: kAfterAdhanTextShadow,
                  fontFamily: StringManager.getFontFamilyByString(
                    translatedText!,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ).animate().fadeIn(delay: .5.seconds).addRepaintBoundary(),
          ),
      ],
    );
  }
}
