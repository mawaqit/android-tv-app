import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_ar.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/pages/home/widgets/AboveSalahBar.dart';
import 'package:mawaqit/src/widgets/display_text_widget.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/responsive_mini_salah_bar_widget.dart';
import 'package:mawaqit/src/services/audio_manager.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

import '../widgets/salah_items/responsive_mini_salah_bar_turkish_widget.dart';

class DuaaEftarScreen extends StatefulWidget {
  const DuaaEftarScreen({Key? key}) : super(key: key);

  @override
  State<DuaaEftarScreen> createState() => _DuaaEftarScreenState();
}

class _DuaaEftarScreenState extends State<DuaaEftarScreen> {
  late AudioManager audioManager;

  @override
  void initState() {
    audioManager = context.read<AudioManager>();
    final mosqueManager = context.read<MosqueManager>();

    if (!mosqueManager.typeIsMosque) audioManager.loadAssetsAndPlay('assets/voices/duaa_iftar.mp3');

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arabic = AppLocalizationsAr();
    final mosqueProvider = context.read<MosqueManager>();

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(R.ASSETS_BACKGROUNDS_ISLAMIC_CONTENT_BACKGROUND_WEBP),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          AboveSalahBar(),
          Expanded(
            child: DisplayTextWidget(
              title: arabic.duaaElEftar,
              arabicText: arabic.duaaElEftarText,
              translatedText: S.of(context).duaaElEftarText,
              mainAxisAlignment: MainAxisAlignment.start,
            ),
          ),
          mosqueProvider.times!.isTurki ? ResponsiveMiniSalahBarTurkishWidget() : ResponsiveMiniSalahBarWidget(),
        ],
      ),
    );
  }
}
