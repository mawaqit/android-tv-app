import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_ar.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/StringUtils.dart';
import 'package:mawaqit/src/pages/home/widgets/HadithScreen.dart';
import 'package:provider/provider.dart';

import '../../../const/constants.dart';
import '../../../services/audio_manager.dart';
import '../../../services/mosque_manager.dart';
import '../../../themes/UIShadows.dart';

class AfterAdhanSubScreen extends StatefulWidget {
  const AfterAdhanSubScreen({Key? key, this.onDone}) : super(key: key);

  final VoidCallback? onDone;

  @override
  State<AfterAdhanSubScreen> createState() => _AfterAdhanSubScreenState();
}

class _AfterAdhanSubScreenState extends State<AfterAdhanSubScreen> {
  final arTranslation = AppLocalizationsAr();
  final minimumDelay = Future.delayed(Duration(seconds: 20));

  AudioManager? audioProvider;

  closeAfterAdhanScreen() async {
    await minimumDelay;
    widget.onDone?.call();
  }

  @override
  void initState() {
    final mosqueManager = context.read<MosqueManager>();
    final mosqueConfig = mosqueManager.mosqueConfig!;
    audioProvider = context.read<AudioManager>();
    if (mosqueConfig.duaAfterAzanEnabled!) {
      if (mosqueManager.adhanVoiceEnable() && !mosqueManager.typeIsMosque) {
        audioProvider!.loadAndPlayDuaAfterAdhanVoice(
          mosqueConfig,
          onDone: closeAfterAdhanScreen,
        );
      } else {
        Future.delayed(30.seconds, widget.onDone);
      }
    } else {
      widget.onDone?.call();
    }

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
          image: AssetImage(R.ASSETS_BACKGROUNDS_BACKGROUND_ADHKAR_JPG),
          fit: BoxFit.cover,
        ),
      ),
      child: HadithWidget(
        maxHeight: 35,
        title: arTranslation.afterAdhanHadithTitle,
        arabicText: arTranslation.afterSalahHadith,
        translatedTitle: S.of(context).afterAdhanHadithTitle,
        translatedText: S.of(context).afterSalahHadith,
      ),
    );
  }
}
