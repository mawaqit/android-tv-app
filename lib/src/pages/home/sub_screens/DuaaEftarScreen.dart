import 'package:flutter/material.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/pages/home/widgets/HadithScreen.dart';
import 'package:mawaqit/src/services/audio_manager.dart';
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
    audioManager.loadAssetsAndPlay('assets/voices/duaa_iftar.mp3');

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

    return HadithWidget(
      title: arabic.duaaElEftar,
      arabicText: arabic.duaaElEftarText,
      translatedText: S.of(context).duaaElEftarText,
    );
  }
}
