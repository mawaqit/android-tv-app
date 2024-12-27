import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/repaint_boundaries.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/services/theme_manager.dart';
import 'package:mawaqit/src/state_management/random_hadith/random_hadith_notifier.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_ar.dart';

class HadithWidget extends ConsumerWidget {
  HadithWidget({
    Key? key,
    this.title,
    this.arabicText,
    this.translatedTitle,
    this.translatedText,
    this.textDirection,
    this.maxHeight = 50,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.padding,
  }) : super(key: key);

  final EdgeInsetsGeometry? padding;
  final String? title;
  final String? arabicText;
  final String? translatedTitle;
  final String? translatedText;
  final TextDirection? textDirection;
  final MainAxisAlignment mainAxisAlignment;
  final double maxHeight;

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
    final jumuaArHadith = AppLocalizationsAr().jumuaaHadith;

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
            _buildContentText(
              text: arabicText!,
              context: context,
              hadithLanguage: hadithLang,
              textDirection: TextDirection.rtl,
              delay: .1.seconds,
              isJumua: arabicText == jumuaArHadith,
            ),
          if (translatedTitle != null && translatedTitle != title && translatedTitle != '')
            titleText(
              translatedTitle!,
              textDirection: textDirection,
              delay: .2.seconds,
            ),
          if (translatedText != null && translatedText != arabicText && translatedText != '')
            _buildContentText(
              text: translatedText!,
              context: context,
              hadithLanguage: hadithLang,
              textDirection: textDirection,
              delay: .3.seconds,
              isJumua: translatedText == S.of(context).jumuaaHadith,
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

  Widget _buildContentText({
    required String text,
    required BuildContext context,
    required Locale hadithLanguage,
    TextDirection? textDirection,
    Duration? delay,
    required bool isJumua,
  }) {
    return Flexible(
      fit: isJumua ? FlexFit.loose : FlexFit.tight,
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight.vh),
        child: Padding(
          key: ValueKey(text),
          padding: EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: isJumua ? 0.0 : 16.0,
          ),
          child: AutoSizeText(
            text,
            style: isJumua
                ? TextStyle(
                    fontSize: 600,
                    color: Colors.white,
                    shadows: kIqamaCountDownTextShadow,
                  )
                : context.getLocalizedTextStyle(locale: hadithLanguage).copyWith(
                      color: Colors.white,
                      shadows: kIqamaCountDownTextShadow,
                      fontWeight: FontWeight.bold,
                      fontSize: 600,
                    ),
            textAlign: TextAlign.center,
            textDirection: textDirection,
          ).animate().fadeIn(delay: delay).addRepaintBoundary(),
        ),
      ),
    );
  }
}
