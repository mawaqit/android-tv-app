import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mawaqit/generated/l10n.dart';

class JumuaHadithSubScreen extends StatelessWidget {
  const JumuaHadithSubScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final jumuaTimeStartedAr = S.of(context).jumuaaScreenTitle;
    final jumuaHadith =
        'عَنْ أَبِي هُرَيْرَةَ قَالَ قَالَ رَسُولُ اللَّهِ صَلَّى اللَّه عَلَيْهِ وَسَلَّمَ مَنْ تَوَضَّأَ فَأَحْسَنَ الْوُضُوءَ ثُمَّ أَتَى الْجُمُعَةَ فَاسْتَمَعَ وَأَنْصَتَ غُفِرَ لَهُ مَا بَيْنَهُ وَبَيْنَ الْجُمُعَةِ وَزِيَادَةُ ثَلاثَةِ أَيَّامٍ وَمَنْ مَسَّ الْحَصَى فَقَدْ لَغَا';

    return Column(
      children: [
        Container(
          child: Text(
            jumuaTimeStartedAr,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              fontFamily: 'hafs',
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: AutoSizeText(
              jumuaHadith,
              minFontSize: 24,
              stepGranularity: 6,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                fontFamily: 'hafs',
              ),
            ),
          ),
        ),
        if (!isArabic)
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: AutoSizeText(
                S.of(context).jumuaaHadith,
                minFontSize: 24,
                stepGranularity: 12,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        SizedBox(height: 40),
      ],
    );
  }
}
