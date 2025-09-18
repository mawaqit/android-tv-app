import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/repaint_boundaries.dart';
import 'package:mawaqit/src/services/theme_manager.dart';
import 'package:mawaqit/src/state_management/random_hadith/random_hadith_notifier.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:sizer/sizer.dart';

class DisplayTextWidget extends ConsumerWidget {
  const DisplayTextWidget({
    super.key,
    this.title,
    this.arabicText,
    this.translatedTitle,
    this.translatedText,
    this.textDirection,
    this.maxHeight = 50,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.padding,
    this.isHadith = false, // Add this flag to determine the mode
  });

  // Factory constructor for normal display
  factory DisplayTextWidget.normal({
    Key? key,
    required String title,
    required String arabicText,
    required String translatedTitle,
    required String translatedText,
    TextDirection? textDirection,
    double maxHeight = 50,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
    EdgeInsetsGeometry? padding,
  }) {
    return DisplayTextWidget(
      key: key,
      title: title,
      arabicText: arabicText,
      translatedTitle: translatedTitle,
      translatedText: translatedText,
      textDirection: textDirection,
      maxHeight: maxHeight,
      mainAxisAlignment: mainAxisAlignment,
      padding: padding,
      isHadith: false,
    );
  }

  // Factory constructor for hadith display
  factory DisplayTextWidget.hadith({
    Key? key,
    String? translatedText,
    TextDirection? textDirection,
    double maxHeight = 50,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
    EdgeInsetsGeometry? padding,
  }) {
    return DisplayTextWidget(
      key: key,
      translatedText: translatedText,
      textDirection: textDirection,
      maxHeight: maxHeight,
      mainAxisAlignment: mainAxisAlignment,
      padding: padding,
      isHadith: true,
    );
  }

  final EdgeInsetsGeometry? padding;
  final String? title;
  final String? arabicText;
  final String? translatedTitle;
  final String? translatedText;
  final TextDirection? textDirection;
  final MainAxisAlignment mainAxisAlignment;
  final double maxHeight;
  final bool isHadith;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hadithLang = ref.watch<Locale>(
      randomHadithNotifierProvider.select((state) {
        try {
          final lang = state.maybeWhen(
            orElse: () => 'ar',
            data: (state) => state.language,
          );
          return Locale(lang);
        } catch (e) {
          return Locale('ar');
        }
      }),
    );

    return Padding(
      padding: padding ?? EdgeInsets.all(1.vwr),
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        children: [
          if (title != null && title != '')
            titleText(
              title!,
              textDirection: TextDirection.rtl,
            ),
          if (arabicText != null && arabicText != '')
            contentText(
              arabicText!,
              context,
              hadithLang,
              textDirection: TextDirection.rtl,
              delay: .1.seconds,
            ),
          if (translatedTitle != null && translatedTitle != title && translatedTitle != '')
            titleText(
              translatedTitle!,
              textDirection: textDirection,
              delay: .2.seconds,
            ),
          if (translatedText != null && translatedText != arabicText && translatedText != '')
            contentText(
              translatedText!,
              context,
              hadithLang,
              textDirection: textDirection,
              delay: .3.seconds,
            ),
        ],
      ),
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
        fontSize: 4.vwr,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: kAfterAdhanTextShadow,
      ),
      textAlign: TextAlign.center,
      textDirection: textDirection,
    ).animate(delay: delay).slide().fade().addRepaintBoundary();
  }

  Widget contentText(
    String text,
    BuildContext context,
    Locale hadithLanguage, {
    TextDirection? textDirection,
    Duration? delay,
  }) {
    return isHadith
        ? Expanded(
            child: Container(
              width: double.infinity,
              child: Padding(
                key: ValueKey(text),
                padding: EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: isHadith ? 16.0 : 0.0,
                ),
                child: AutoSizeText(
                  text,
                  style: isHadith
                      ? _getHadithTextStyle(context, hadithLanguage)
                      : TextStyle(
                          fontSize: 32.sp,
                          color: Colors.white,
                          shadows: kIqamaCountDownTextShadow,
                        ),
                  textAlign: TextAlign.center,
                  textDirection: textDirection,
                  maxLines: isHadith ? null : 1,
                ).animate().fadeIn(delay: delay).addRepaintBoundary(),
              ),
            ),
          )
        : Flexible(
            fit: FlexFit.loose,
            child: Container(
              constraints: BoxConstraints(maxHeight: maxHeight.vh),
              child: Padding(
                key: ValueKey(text),
                padding: EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: isHadith ? 16.0 : 0.0,
                ),
                child: AutoSizeText(
                  text,
                  style: isHadith
                      ? _getHadithTextStyle(context, hadithLanguage)
                      : TextStyle(
                          fontSize: 600,
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

  // Helper method to get hadith text style with Turkish font fix
  TextStyle _getHadithTextStyle(BuildContext context, Locale hadithLanguage) {
    // Get the base style from context (keeps all existing logic)
    final baseStyle = context.getLocalizedTextStyle(locale: hadithLanguage).copyWith(
          color: Colors.white,
          shadows: kIqamaCountDownTextShadow,
          fontWeight: FontWeight.bold,
          fontSize: 32.sp,
        );

    // For Turkish, override only the font family to use system font
    if (hadithLanguage.languageCode == 'tr') {
      return baseStyle.copyWith(
        fontFamily: null,
        fontFamilyFallback: null,
      );
    }

    // For all other languages, return the original style
    return baseStyle;
  }
}
