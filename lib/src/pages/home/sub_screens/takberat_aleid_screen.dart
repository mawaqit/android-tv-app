import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/pages/home/widgets/AboveSalahBar.dart';
import 'package:mawaqit/src/widgets/display_text_widget.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/responsive_mini_salah_bar_widget.dart';
import 'package:mawaqit/src/services/audio_manager.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

/// this screen will show the takberat aleid during the eid day
class TakberatAleidScreen extends StatefulWidget {
  const TakberatAleidScreen({Key? key}) : super(key: key);

  @override
  State<TakberatAleidScreen> createState() => _TakberatAleidScreenState();
}

class _TakberatAleidScreenState extends State<TakberatAleidScreen> {
  late AudioManager audioManager;

  startTakbber() async {
    /// give 5 seconds silence between takberat
    Future.delayed(5.seconds);

    audioManager.loadAssetsAndPlay('assets/voices/takbir-aid.mp3', onDone: startTakbber);
  }

  @override
  void initState() {
    audioManager = context.read<AudioManager>();
    final mosqueManager = context.read<MosqueManager>();

    /// don't show takbirat in mosque
    if (!mosqueManager.typeIsMosque) startTakbber();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(R.ASSETS_BACKGROUNDS_ISLAMIC_CONTENT_BACKGROUND_WEBP),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            AboveSalahBar(),
            Expanded(
              child: DisplayTextWidget(
                title: S.of(context).eidMubarak,
                translatedText: S.of(context).takbeerAleidText,
                mainAxisAlignment: MainAxisAlignment.start,
              ),
            ),
            ResponsiveMiniSalahBarWidget(),
          ],
        ),
      ),
    );
  }
}
