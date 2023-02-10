import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mawaqit/generated/l10n.dart';
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
  final kTitleArabic = 'دعاء ما بعد الأذان';

  final kHadithArabic =
      ' اللَّهمَّ ربَّ هذِهِ الدَّعوةِ التَّامَّةِ ، والصَّلاةِ القائمةِ ، آتِ سيِّدَنا مُحمَّدًا الوسيلةَ والفَضيلةَ ، وابعثهُ مقامًا مَحمودًا الَّذي وعدتَهُ، إنَّكَ لا تخلفُ الميعادَ.';

  @override
  void initState() {
    final mosqueConfig = context.read<MosqueManager>().mosqueConfig;
    final audioProvider = context.read<AudioManager>();
    if (mosqueConfig!.duaAfterAzanEnabled! && !context.read<MosqueManager>().typeIsMosque) {
      audioProvider.loadAndPlayDuaAfterAdhanVoice(mosqueConfig, onDone: widget.onDone);
    } else {
      widget.onDone?.call();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              kTitleArabic,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 62,
                  color: Colors.white,
                  shadows: kAfterAdhanTextShadow,
                  fontFamily: StringManager.fontFamilyKufi),
            ),
            SizedBox(
              width: isArabic?110.vw:200.vw,
              child: AutoSizeText(
                stepGranularity: 1,
                kHadithArabic,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 6.2.vw,
                    color: Colors.white,
                    shadows: kAfterAdhanTextShadow,
                    fontFamily: StringManager.fontFamilyKufi),
              ),
            ),
            if (Localizations.localeOf(context).languageCode != 'ar') ...[
              AutoSizeText(
                S.of(context).afterSalahHadithTitle,
                stepGranularity: 1,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 6.2.vw,
                  color: Colors.white,
                  shadows: kIqamaCountDownTextShadow,
                ),
              ),
              SizedBox(
                width: 200.vw,
                child: Text(
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
              SizedBox(
                height: 2.5.vh,
              )
            ]
          ],
        ),
      ),
    );
  }
}
