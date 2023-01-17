import 'package:flutter/material.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:provider/provider.dart';

import '../../../services/audio_manager.dart';
import '../../../services/mosque_manager.dart';

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
    if (mosqueConfig!.duaAfterAzanEnabled!) {
      audioProvider.loadAndPlayDuaAfterAdhanVoice(mosqueConfig, onDone: widget.onDone);
    } else {
      widget.onDone?.call();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            kTitleArabic,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 40,
              color: Colors.lightGreenAccent,
            ),
          ),
          SizedBox(
            width: 1000,
            child: Text(
              kHadithArabic,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 36,
                color: Colors.white,
              ),
            ),
          ),
          if (Localizations.localeOf(context).languageCode != 'ar') ...[
            Text(
              S.of(context).afterSalahHadithTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
                color: Colors.lightGreenAccent,
              ),
            ),
            SizedBox(
              width: 1000,
              child: Text(
                S.of(context).afterSalahHadith,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  color: Colors.white,
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
