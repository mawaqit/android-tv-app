import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/mawaqit_icons_icons.dart';
import 'package:mawaqit/src/helpers/repaint_boundaries.dart';
import 'package:mawaqit/src/pages/home/widgets/FlashAnimation.dart';
import 'package:mawaqit/src/pages/home/widgets/mosque_background_screen.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/responsive_mini_salah_bar_widget.dart';
import 'package:mawaqit/src/services/audio_manager.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';

import '../widgets/mosque_header.dart';

class AdhanSubScreen extends StatefulWidget {
  const AdhanSubScreen({Key? key, this.onDone, this.forceAdhan = false}) : super(key: key);

  final VoidCallback? onDone;

  /// used for before fajr alert
  final bool forceAdhan;

  @override
  State<AdhanSubScreen> createState() => _AdhanSubScreenState();
}

class _AdhanSubScreenState extends State<AdhanSubScreen> {
  AudioManager? audioManager;

  /// if mosque using Beb sound we will wait for minutes delay
  closeAdhanScreen() async {
    if (mounted) widget.onDone?.call();
  }

  @override
  void initState() {
    final mosqueManager = context.read<MosqueManager>();
    final mosqueConfig = mosqueManager.mosqueConfig;
    audioManager = context.read<AudioManager>();
    final duration = mosqueManager.getAdhanDuration();

    Future.delayed(duration, () {
      closeAdhanScreen();
    });

    if (widget.forceAdhan || mosqueManager.adhanVoiceEnable()) {
      audioManager!.loadAndPlayAdhanVoice(
        mosqueConfig,
        onDone: () {},
        useFajrAdhan: mosqueManager.salahIndex == 0,
      );
    } else {
      closeAdhanScreen();
    }
    super.initState();
  }

  @override
  void dispose() {
    audioManager?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mosqueProvider = context.read<MosqueManager>();
    final mosque = mosqueProvider.mosque!;

    return MosqueBackgroundScreen(
      child: Column(
        children: [
          Directionality(textDirection: TextDirection.ltr, child: MosqueHeader(mosque: mosque)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.vw),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  textBaseline: TextBaseline.alphabetic,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  children: [
                    Icon(MawaqitIcons.icon_adhan, size: 12.vw)
                        .animate()
                        .slideX(begin: -1, delay: .5.seconds)
                        .fadeIn()
                        .addRepaintBoundary(),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.vw),
                      child: Text(
                        S.of(context).alAdhan,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.vw,
                          color: Colors.white,
                          shadows: kHomeTextShadow,
                        ),
                      ),
                    ).animate().moveY(begin: -120).fade().addRepaintBoundary(),
                    Icon(MawaqitIcons.icon_adhan, size: 12.vw)
                        .animate()
                        .slideX(begin: 1, delay: .5.seconds)
                        .fadeIn()
                        .addRepaintBoundary(),
                  ],
                ).flashAnimation(),
              ),
            ),
          ),
          ResponsiveMiniSalahBarWidget(activeItem: mosqueProvider.salahIndex),
          SizedBox(height: 2.vh),
        ],
      ),
    );
  }
}
