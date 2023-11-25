import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/repaint_boundaries.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';

import '../../../helpers/font_manager.dart';

/// this screen made to show of the hadith screen
class HadithWidget extends StatelessWidget {
  HadithWidget({
    Key? key,
    required this.locale,
    this.title,
    this.arabicText,
    this.translatedTitle,
    this.translatedText,
    this.textDirection,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.padding,
  }) : super(key: key);

  final EdgeInsetsGeometry? padding;

  /// The main title of the screen
  final String? title;

  /// arabic text of the hadith screen
  final String? arabicText;

  /// translated title of the hadith
  final String? translatedTitle;

  /// locale of the translated text
  final String locale;

  /// translated text of the hadith
  final String? translatedText;

  /// force the text direction of the translated text
  /// used for random hadith because hadith language is not the same as the app language
  final TextDirection? textDirection;

  /// alignment of the item along the main axis
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.all(2.vwr),
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        children: [
          if (title != null && title != '')
            titleText(
              title!,
              textDirection: TextDirection.rtl,
              locale: locale,
            ),
          if (arabicText != null && arabicText != '')
            contentText(
              arabicText!,
              textDirection: TextDirection.rtl,
              locale: 'ar',
              delay: .1.seconds,
            ),
          if (translatedTitle != null && translatedTitle != title && translatedTitle != '')
            titleText(
              translatedTitle!,
              locale: locale,
              textDirection: textDirection,
              delay: .2.seconds,
            ),
          if (translatedText != null && translatedText != arabicText && translatedText != '')
            contentText(
              translatedText!,
              locale: locale,
              textDirection: textDirection,
              delay: .3.seconds,
            ),
        ],
      ),
    );
  }

  Widget titleText(
    String text, {
     required  String locale,
    TextDirection? textDirection,
    Duration? delay,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 6.2.vwr,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontFamily: FontManager.getFontFamily(locale ),
      ),
      textAlign: TextAlign.center,
      textDirection: textDirection,
    ).animate(delay: delay).slide().fade().addRepaintBoundary();
  }

  Widget contentText(
    String text, {
        required  String locale,
    TextDirection? textDirection,
    Duration? delay,
  }) {
    return Flexible(
      fit: FlexFit.loose,
      child: Container(
        constraints: BoxConstraints(maxHeight: 50.vh),
        child: Padding(
          key: ValueKey(text),
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: AutoSizeText(
            text,
            style: TextStyle(
              fontSize: 600,
              fontFamily: FontManager.getFontFamily(locale),
              color: Colors.white,
              shadows: kIqamaCountDownTextShadow,
            ),
            textAlign: TextAlign.center,
            textDirection: textDirection,
          ).animate().fadeIn(delay: delay).addRepaintBoundary(),
        ),
      ),
    );
  }
}
