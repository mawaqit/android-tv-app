import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/mawaqit_icons_icons.dart';
import 'package:mawaqit/src/pages/home/widgets/mosque_background_screen.dart';
import 'package:mawaqit/src/services/audio_manager.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';
import '../../../themes/UIShadows.dart';
import '../widgets/SalahItem.dart';
import '../widgets/SalahTimesBar.dart';
import '../widgets/ShurukWidget.dart';
import '../widgets/TimeWidget.dart';
import '../widgets/footer.dart';
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
  @override
  void initState() {
    final mosqueManager = context.read<MosqueManager>();
    final salahIndex = mosqueManager.salahIndex;
    final mosqueConfig = mosqueManager.mosqueConfig;

    final audioProvider = context.read<AudioManager>();

    /// if there are no adhan voice
    if (mosqueConfig?.adhanVoice == null) {
      Future.delayed(Duration(minutes: 2), widget.onDone);
      return super.initState();
    }

    if (widget.forceAdhan || mosqueConfig?.adhanEnabledByPrayer![salahIndex] == "1") {
      audioProvider.loadAndPlayAdhanVoice(mosqueConfig, onDone: widget.onDone);
    } else {
      Future.delayed(Duration(minutes: 2), widget.onDone);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mosqueProvider = context.read<MosqueManager>();
    final mosque = mosqueProvider.mosque!;
    double adhanIconSize = 15.vh;
    final iconColor = Colors.white;

    return MosqueBackgroundScreen(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Directionality(textDirection: TextDirection.ltr, child: MosqueHeader(mosque: mosque)),
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Animate(
                  onPlay: (controller) {
                    controller.repeat(reverse: true);
                  },
                  effects: [FadeEffect(curve: Curves.fastLinearToSlowEaseIn, delay: 1.seconds, begin: 1, end: 0)],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        MawaqitIcons.icon_adhan,
                        size: adhanIconSize,
                        shadows: kHomeTextShadow,
                        color: iconColor,
                      ),
                      Text(
                        "    ${S.of(context).alAdhan}    ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.vh,
                          // height: 2,
                          color: Colors.white,
                          shadows: kHomeTextShadow,
                        ),
                      ),
                      Icon(
                        MawaqitIcons.icon_adhan,
                        size: adhanIconSize,
                        shadows: kHomeTextShadow,
                        color: iconColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 7.3.vh, right: 1.vw),
              child: SalahTimesBar(),
            ),
          ],
        ),
        Directionality(textDirection: TextDirection.ltr, child: Footer()),
      ],
    ));
  }
}
