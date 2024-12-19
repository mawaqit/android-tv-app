import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';
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

    return RepaintBoundary(
      child: Marquee(
        key: ValueKey(flash!.content),
        textDirection: flash.orientation == 'rtl' ? TextDirection.rtl : TextDirection.ltr,
        text: flash.content ?? '',
        velocity: 90,
        blankSpace: 400,
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
      ),
    );
  }
}
