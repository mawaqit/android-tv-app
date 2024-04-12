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
                    Flexible(
                      fit: FlexFit.loose,
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: FittedBox(
                          child: Text(
                            S.of(context).salatKhayrMinaNawm,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.vw,
                              // height: 2,
                              color: Colors.white,
                              shadows: kHomeTextShadow,
                            ),
                          ).animate().slideY(begin: -1, delay: .5.seconds).fadeIn().addRepaintBoundary(),
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
          ResponsiveMiniSalahBarWidget(),
          SizedBox(height: 2.vw),
        ],
      ),
    );
  }
}
