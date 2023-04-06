import 'package:flutter/material.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/pages/home/widgets/AboveSalahBar.dart';
import 'package:mawaqit/src/pages/home/widgets/HadithScreen.dart';
import 'package:mawaqit/src/pages/home/widgets/SalahTimesBar.dart';
import 'package:mawaqit/src/services/audio_manager.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_ar.dart';

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
    audioManager.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arabic = AppLocalizationsAr();

    return Column(
      children: [
        AboveSalahBar(),
        Expanded(
          child: HadithWidget(
            title: arabic.duaaElEftar,
            arabicText: arabic.duaaElEftarText,
            translatedText: S.of(context).duaaElEftarText,
            mainAxisAlignment: MainAxisAlignment.start,
          ),
        ),
        SalahTimesBar(miniStyle: true, microStyle: true),
        SizedBox(height: 10),
      ],
    );
  }
}
