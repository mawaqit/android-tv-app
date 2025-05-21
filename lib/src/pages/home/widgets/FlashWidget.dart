import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:provider/provider.dart';
import '../../../helpers/HexColor.dart';
import '../../../models/flash.dart';
import '../../../services/mosque_manager.dart';
import '../../../themes/UIShadows.dart';

class FlashWidget extends StatefulWidget {
  const FlashWidget({Key? key}) : super(key: key);

  @override
  State<FlashWidget> createState() => _FlashWidgetState();
}

class _FlashWidgetState extends State<FlashWidget> {
  @override
  Widget build(BuildContext context) {
    final isFlashEnabled = context.select<MosqueManager, bool>((mosque) => mosque.flashEnabled);
    final flash = context.select<MosqueManager, Flash?>((mosque) => mosque.mosque?.flash);
    if (!isFlashEnabled) return SizedBox();
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final appLanguage = Provider.of<AppLanguage>(context);
    if (!isFlashEnabled) return SizedBox();

    TextDirection getTextDirection() {
      if (isPortrait && appLanguage.appLocal.toLanguageTag() == "ar") {
        return flash?.orientation == 'rtl' ? TextDirection.ltr : TextDirection.rtl;
      } else {
        return flash?.orientation == 'rtl' ? TextDirection.rtl : TextDirection.ltr;
      }
    }

    return RepaintBoundary(
      child: Marquee(
        key: ValueKey(flash!.content),
        textDirection: getTextDirection(),
        text: flash.content ?? '',
        velocity: 50,
        blankSpace: 50.0,
        style: TextStyle(
          fontFamily:
              flash.orientation == 'rtl' ? GoogleFonts.notoKufiArabic().fontFamily : GoogleFonts.roboto().fontFamily,
          height: 1,
          fontSize: 3.4.vwr,
          fontWeight: FontWeight.bold,
          wordSpacing: 3,
          shadows: kHomeTextShadow,
          color: HexColor(flash.color ?? "#FFFFFF"),
        ),
        accelerationDuration: Duration(seconds: 1),
        accelerationCurve: Curves.easeInOut,
        decelerationDuration: Duration(seconds: 1),
        decelerationCurve: Curves.easeInOut,
        showFadingOnlyWhenScrolling: true,
        fadingEdgeStartFraction: 0.1,
        fadingEdgeEndFraction: 0.1,
      ),
    );
  }
}
