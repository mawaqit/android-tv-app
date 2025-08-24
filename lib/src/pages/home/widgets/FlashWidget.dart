import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:provider/provider.dart';
import 'package:mawaqit/src/helpers/HexColor.dart';
import 'package:mawaqit/src/models/flash.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';

class FlashWidget extends StatefulWidget {
  const FlashWidget({super.key});

  @override
  State<FlashWidget> createState() => _FlashWidgetState();
}

class _FlashWidgetState extends State<FlashWidget> {
  // Cache TextStyle to avoid recreation on each build
  TextStyle? _cachedTextStyle;
  String? _lastFlashColor;

  TextStyle _getTextStyle(String? color) {
    if (_cachedTextStyle == null || _lastFlashColor != color) {
      _lastFlashColor = color;
      _cachedTextStyle = TextStyle(
        // Use system fonts for better performance on low-spec devices
        fontFamily: null, // Let system choose appropriate font
        height: 1,
        fontSize: 3.0.vwr, // Slightly smaller font for better performance
        fontWeight: FontWeight.normal, // Reduced from bold for better performance
        wordSpacing: 2, // Reduced word spacing for simpler rendering
        // Removed shadows for better performance on low-spec devices
        color: HexColor(color ?? "#FFFFFF"),
      );
    }
    return _cachedTextStyle!;
  }

  @override
  Widget build(BuildContext context) {
    final isFlashEnabled = context.select<MosqueManager, bool>((mosque) => mosque.flashEnabled);
    final flash = context.select<MosqueManager, Flash?>((mosque) => mosque.mosque?.flash);
    if (!isFlashEnabled) return const SizedBox();
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final appLanguage = Provider.of<AppLanguage>(context);
    if (!isFlashEnabled) return const SizedBox();

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
        velocity: 15, // Further reduced for low-spec devices
        blankSpace: 50.0,
        pauseAfterRound: Duration(seconds: 3), // Longer pause for low-spec devices
        startAfter: Duration(seconds: 2), // Longer delay for low-spec devices
        style: _getTextStyle(flash.color),
        accelerationDuration: Duration.zero, // Remove acceleration for performance
        accelerationCurve: Curves.linear,
        decelerationDuration: Duration.zero, // Remove deceleration for performance
        decelerationCurve: Curves.linear,
        showFadingOnlyWhenScrolling: false, // Disable fading for better performance
        fadingEdgeStartFraction: 0.0, // No fading edges for low-spec devices
        fadingEdgeEndFraction: 0.0, // No fading edges for low-spec devices
      ),
    );
  }
}
