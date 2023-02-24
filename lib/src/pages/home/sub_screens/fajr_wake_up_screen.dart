import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/StringUtils.dart';
import 'package:mawaqit/src/helpers/mawaqit_icons_icons.dart';
import 'package:mawaqit/src/helpers/repaint_boundaries.dart';
import 'package:mawaqit/src/pages/home/widgets/FlashAnimation.dart';
import 'package:mawaqit/src/pages/home/widgets/SalahTimesBar.dart';
import 'package:mawaqit/src/pages/home/widgets/mosque_background_screen.dart';
import 'package:mawaqit/src/pages/home/widgets/mosque_header.dart';
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
  @override
  void initState() {
    final mosqueManager = context.read<MosqueManager>();
    context.read<AudioManager>().loadAndPlayAdhanVoice(
          mosqueManager.mosqueConfig!,
          onDone: widget.onDone,
          useFajrAdhan: true,
        );

    super.initState();
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
              padding: EdgeInsets.only(top: 4.vh),
              child: FlashAnimation(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      MawaqitIcons.icon_adhan,
                      size: 15.vh,
                      shadows: kHomeTextShadow,
                      color: Colors.white,
                    ).animate().slideX(begin: -2).addRepaintBoundary(),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 70.vw),
                      child: FittedBox(
                        child: Text(
                          S.of(context).salatKhayrMinaNawm,
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
                      size: 15.vh,
                      shadows: kHomeTextShadow,
                      color: Colors.white,
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
