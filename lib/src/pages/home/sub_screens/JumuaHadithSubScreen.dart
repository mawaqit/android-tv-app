import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';

import '../../../helpers/StringUtils.dart';

class JumuaHadithSubScreen extends StatelessWidget {
  const JumuaHadithSubScreen({Key? key, this.onDone}) : super(key: key);

  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    final mosqueConfig = context.read<MosqueManager>().mosqueConfig;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final tr =S.of(context);
    final jumuaTimeStartedAr = tr.jumuaaScreenTitle;
    final jumuaHadith =
        'عَنْ أَبِي هُرَيْرَةَ قَالَ قَالَ رَسُولُ اللَّهِ صَلَّى اللَّه عَلَيْهِ وَسَلَّمَ مَنْ تَوَضَّأَ فَأَحْسَنَ الْوُضُوءَ ثُمَّ أَتَى الْجُمُعَةَ فَاسْتَمَعَ وَأَنْصَتَ غُفِرَ لَهُ مَا بَيْنَهُ وَبَيْنَ الْجُمُعَةِ وَزِيَادَةُ ثَلاثَةِ أَيَّامٍ وَمَنْ مَسَّ الْحَصَى فَقَدْ لَغَا';
    if (mosqueConfig!.jumuaDhikrReminderEnabled!) {
      return Column(
        children: [
          SizedBox(height: 10,),
          Container(
            child: AutoSizeText(
              jumuaTimeStartedAr,
              style: TextStyle(
                fontSize: 6.2.vw,
                fontWeight: FontWeight.bold,
                fontFamily: StringManager.getFontFamilyByString(jumuaTimeStartedAr),
                color: Colors.white,
                shadows: kAfterAdhanTextShadow
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: AutoSizeText(
                jumuaHadith,
                minFontSize: 24,
                stepGranularity: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 6.2.vw,
                  fontWeight: FontWeight.bold,
                  fontFamily: StringManager.fontFamilyKufi,
                  color: Colors.white,
                    shadows: kAfterAdhanTextShadow

                ),
              ),
            ),
          ),
          if (!isArabic)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: AutoSizeText(
                  tr.jumuaaHadith,
                  minFontSize: 24,
                  stepGranularity: 12,

                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 3.vw,
                    fontFamily: StringManager.getFontFamilyByString(tr.jumuaaHadith),
                      shadows: kAfterAdhanTextShadow

                  ),
                ),
              ),
            ),
          SizedBox(height: 20),
        ],
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
    );
  }
}
