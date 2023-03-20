import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/StringUtils.dart';
import 'package:mawaqit/src/helpers/mawaqit_icons_icons.dart';
import 'package:mawaqit/src/helpers/repaint_boundaries.dart';
import 'package:mawaqit/src/pages/home/widgets/mosque_background_screen.dart';
import 'package:mawaqit/src/services/audio_manager.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

import '../../../themes/UIShadows.dart';
import '../widgets/FlashAnimation.dart';
import '../widgets/SalahTimesBar.dart';
import '../widgets/mosque_header.dart';

class AdhanSubScreen extends StatefulWidget {
  const AdhanSubScreen({Key? key, this.onDone, this.forceAdhan = false})
      : super(key: key);

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

    if (mosqueManager.isShortIqamaDuration(mosqueManager.salahIndex)) {
      /// this will close this screen after 90 seconds
      closeAdhanScreen();
    }

    if (widget.forceAdhan || mosqueManager.adhanVoiceEnable()) {
      audioManager!.loadAndPlayAdhanVoice(
        mosqueConfig,
        onDone: closeAdhanScreen,
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
    double adhanIconSize = 15.vh;
    final iconColor = Colors.white;
    final isArabic = context.read<AppLanguage>().isArabic();

    return MosqueBackgroundScreen(
      child: Column(
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: MosqueHeader(mosque: mosque),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: isArabic ? 4 : 4.vh),
              child: FlashAnimation(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      MawaqitIcons.icon_adhan,
                      size: adhanIconSize,
                      shadows: kHomeTextShadow,
                      color: iconColor,
                    ).animate().slideX(begin: -2).addRepaintBoundary(),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 70.vw),
                      child: FittedBox(
                        child: Text(
                          "${S.of(context).alAdhan}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.vh,
                            fontFamily: StringManager.getFontFamilyByString(
                                S.of(context).alAdhan),
                            // height: 2,
                            color: Colors.white,
                            shadows: kHomeTextShadow,
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .slideY(begin: -1, delay: .5.seconds)
                        .fadeIn()
                        .addRepaintBoundary(),
                    Icon(
                      MawaqitIcons.icon_adhan,
                      size: adhanIconSize,
                      shadows: kHomeTextShadow,
                      color: iconColor,
                    ).animate().slideX(begin: 2).addRepaintBoundary(),
                  ],
                ),
              ),
            ),
          ),
          SalahTimesBar(),
          SizedBox(height: 2.vw),
        ],
      ),
    );
  }
}
