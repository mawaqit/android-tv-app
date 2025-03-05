import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/mawaqit_icons_icons.dart';
import 'package:mawaqit/src/helpers/repaint_boundaries.dart';
import 'package:mawaqit/src/pages/home/widgets/FlashAnimation.dart';
import 'package:mawaqit/src/pages/home/widgets/mosque_background_screen.dart';
import 'package:mawaqit/src/pages/home/widgets/mosque_header.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/responsive_mini_salah_bar_widget.dart';
import 'package:mawaqit/src/services/audio_manager.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';

import '../widgets/salah_items/responsive_mini_salah_bar_turkish_widget.dart';

class FajrWakeUpSubScreen extends StatefulWidget {
  const FajrWakeUpSubScreen({Key? key, this.onDone}) : super(key: key);

  final VoidCallback? onDone;

  @override
  State<FajrWakeUpSubScreen> createState() => _FajrWakeUpSubScreenState();
}

class _FajrWakeUpSubScreenState extends State<FajrWakeUpSubScreen> {
  late AudioManager audioManager;

  @override
  void initState() {
    final mosqueManager = context.read<MosqueManager>();
    audioManager = context.read<AudioManager>();
    audioManager.loadAndPlayAdhanVoice(
      mosqueManager.mosqueConfig!,
      onDone: widget.onDone,
      useFajrAdhan: true,
    );

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mosqueProvider = context.watch<MosqueManager>();
    final mosque = mosqueProvider.mosque!;

    return MosqueBackgroundScreen(
      child: Column(
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: MosqueHeader(mosque: mosque),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.vw),
              child: FlashAnimation(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      MawaqitIcons.icon_adhan,
                      size: 12.vw,
                      shadows: kHomeTextShadow,
                      color: Colors.white,
                    ).animate().slideX(begin: -2).addRepaintBoundary(),
                    // Then replace your LayoutBuilder with:
                    Flexible(
                      fit: FlexFit.loose,
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal:3.vw),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // Use a higher threshold to better detect height constraints
                            final isHeightConstrained = constraints.maxHeight < 300; // Increased from 100

                            // Adjust font size more aggressively when height constrained
                            double fontSize = isHeightConstrained
                                ? constraints.maxWidth * 0.07 // Smaller font for one line
                                : constraints.maxWidth * 0.12; // Larger font for two lines

                            int maxLines = isHeightConstrained ? 1 : 2;

                            return Center(
                              child: Text(
                                S.of(context).salatKhayrMinaNawm,
                                maxLines: maxLines,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize,
                                  height: isHeightConstrained ? 1.0 : 1.3,
                                  color: Colors.white,
                                  shadows: kHomeTextShadow,
                                ),
                                softWrap: true,
                                overflow: isHeightConstrained ? TextOverflow.ellipsis : TextOverflow.visible,
                              ).animate().slideY(begin: -1, delay: .5.seconds).fadeIn().addRepaintBoundary(),
                            );
                          },
                        ),
                      ),
                    ),
                    Icon(
                      MawaqitIcons.icon_adhan,
                      size: 12.vw,
                      shadows: kHomeTextShadow,
                      color: Colors.white,
                    ).animate().slideX(begin: 2).addRepaintBoundary(),
                  ],
                ),
              ),
            ),
          ),
          mosqueProvider.times!.isTurki ? ResponsiveMiniSalahBarTurkishWidget() : ResponsiveMiniSalahBarWidget()
        ],
      ),
    );
  }
}
