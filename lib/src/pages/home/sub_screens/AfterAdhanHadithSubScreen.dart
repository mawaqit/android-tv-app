import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_ar.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/StringUtils.dart';
import 'package:provider/provider.dart';

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
    final mosqueConfig = context.read<MosqueManager>().mosqueConfig;
    audioProvider = context.read<AudioManager>();
    if (mosqueConfig!.duaAfterAzanEnabled!) {
      audioProvider!.loadAndPlayDuaAfterAdhanVoice(
        mosqueConfig,
        onDone: closeAfterAdhanScreen,
      );
    } else {
      widget.onDone?.call();
    }

    super.initState();
  }

  @override
  void dispose() {
    audioProvider?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            arTranslation.afterSalahHadithTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 5.vw,
              color: Colors.white,
              shadows: kAfterAdhanTextShadow,
              fontFamily: StringManager.fontFamilyKufi,
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: AutoSizeText(
              arTranslation.afterSalahHadith.replaceAll('\n', ''),
              textAlign: TextAlign.center,
              stepGranularity: .5,
              style: TextStyle(
                fontSize: 6.2.vw,
                color: Colors.white,
                shadows: kAfterAdhanTextShadow,
                fontFamily: StringManager.fontFamilyKufi,
              ),
            ),
          ),
          if (!isArabic) ...[
            Text(
              S.of(context).afterSalahHadithTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 5.vw,
                color: Colors.white,
                shadows: kIqamaCountDownTextShadow,
              ),
            ),
            Flexible(
              fit: FlexFit.loose,
              child: AutoSizeText(
                S.of(context).afterSalahHadith,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 62,
                  wordSpacing: 2,
                  color: Colors.white,
                  shadows: kIqamaCountDownTextShadow,
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
