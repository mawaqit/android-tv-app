import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/src/helpers/StringUtils.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

import '../../../themes/UIShadows.dart';

class AfterSalahAzkar extends StatefulWidget {
  AfterSalahAzkar({Key? key, this.onDone}) : super(key: key);

  final VoidCallback? onDone;

  @override
  State<AfterSalahAzkar> createState() => _AfterSalahAzkarState();
}

class _AfterSalahAzkarState extends State<AfterSalahAzkar> {
  /// the item duration in seconds
  final itemDuration = kAzkarDuration.inMinutes / 7 * 60;

  final azkarTitle = 'أذكار بعد الصلاة';

  final azkarList = [
    "أَسْـتَغْفِرُ الله، أَسْـتَغْفِرُ الله، أَسْـتَغْفِرُ الله \nاللّهُـمَّ أَنْـتَ السَّلامُ ، وَمِـنْكَ السَّلام ، تَبارَكْتَ يا ذا الجَـلالِ وَالإِكْـرام اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ",
    "سُـبْحانَ اللهِ، والحَمْـدُ لله، واللهُ أكْـبَر 33 مرة \nلا إِلَٰهَ إلاّ اللّهُ وَحْـدَهُ لا شريكَ لهُ، لهُ الملكُ ولهُ الحَمْد، وهُوَ على كُلّ شَيءٍ قَـدير ",
    "بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ \nقُلۡ أَعُوذُ بِرَبِّ ٱلنَّاسِ ، مَلِكِ ٱلنَّاسِ ، إِلَٰهِ ٱلنَّاسِ ، مِن شَرِّ ٱلۡوَسۡوَاسِ ٱلۡخَنَّاسِ ، ٱلَّذِي يُوَسۡوِسُ فِي صُدُورِ ٱلنَّاسِ ، مِنَ ٱلۡجِنَّةِ وَٱلنَّاسِ",
    "بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ\nقُلۡ أَعُوذُ بِرَبِّ ٱلۡفَلَقِ ، مِن شَرِّ مَا خَلَقَ ، وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ ، وَمِن شَرِ ٱلنَّفَّٰثَٰتِ فِي ٱلۡعُقَدِ ، وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ",
    "بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ\n قُلۡ هُوَ ٱللَّهُ أَحَدٌ ، ٱللَّهُ ٱلصَّمَدُ ، لَمۡ يَلِدۡ وَلَمۡ يُولَدۡ ، وَلَمۡ يَكُن لَّهُۥ كُفُوًا أَحَدُۢ",
    "ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلۡحَيُّ ٱلۡقَيُّومُۚ لَا تَأۡخُذُهُۥ سِنَةٞ وَلَا نَوۡمٞۚ لَّهُۥ مَا فِي ٱلسَّمَٰوَٰتِ وَمَا فِي ٱلۡأَرۡضِۗ مَن ذَا ٱلَّذِي يَشۡفَعُ عِندَهُۥٓ إِلَّا بِإِذۡنِهِۦۚ يَعۡلَمُ مَا بَيۡنَ أَيۡدِيهِمۡ وَمَا خَلۡفَهُمۡۖ وَلَا يُحِيطُونَ بِشَيۡءٖ مِّنۡ عِلۡمِهِۦٓ إِلَّا بِمَا شَآءَۚ وَسِعَ كُرۡسِيُّهُ ٱلسَّمَٰوَٰتِ وَٱلۡأَرۡضَۖ وَلَا يَ‍ُٔودُهُۥ حِفۡظُهُمَاۚ وَهُوَ ٱلۡعَلِيُّ ٱلۡعَظِيمُ",
    "لا إِلَٰهَ إلاّ اللّهُ وحدَهُ لا شريكَ لهُ، لهُ المُـلْكُ ولهُ الحَمْد، وهوَ على كلّ شَيءٍ قَدير، اللّهُـمَّ لا مانِعَ لِما أَعْطَـيْت، وَلا مُعْطِـيَ لِما مَنَـعْت، وَلا يَنْفَـعُ ذا الجَـدِّ مِنْـكَ الجَـد",
  ];

  @override
  void initState() {
    if (context.read<MosqueManager>().mosqueConfig?.duaAfterPrayerEnabled == false)
      Future.delayed(Duration(milliseconds: 80), widget.onDone);
    else
      Future.delayed(kAzkarDuration, widget.onDone);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final screenWidth = MediaQuery.of(context).size.width;

    return StreamBuilder<int>(
      stream: Stream.periodic(Duration(seconds: 1), (computationCount) => computationCount),
      builder: (context, snapshot) {
        final time = snapshot.data ?? 0;

        // if (time >= azkarList.length) widget.onDone?.call();

        int activeHadith = (time ~/ itemDuration) % azkarList.length;

        String translatedHadith = Intl.message('', name: 'AlAthkar_$activeHadith');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "$azkarTitle ${isArabic ? '' : '(${S.of(context).alAthkar})'}",
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                fontFamily: StringManager.fontFamilyKufi
                  ,shadows: kAfterAdhanTextShadow
                  ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,

            ),
            FractionallySizedBox(
              widthFactor: .6,
              child: Divider(color: Colors.white),
            ),
            Expanded(
              child: FittedBox(
                alignment: Alignment.center,
                fit: BoxFit.contain,
                child: SizedBox(
                  width: isArabic || translatedHadith.isEmpty ? screenWidth : screenWidth * 1.5,
                  child: Text(
                    azkarList[activeHadith],
                    style: TextStyle(
                      fontSize: 62,
                      fontWeight: FontWeight.bold,
                      fontFamily: StringManager.getFontFamily(context),
                      color: Colors.white,
                        shadows: kIqamaCountDownTextShadow
                    ),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            if (!isArabic && translatedHadith.isNotEmpty)
              Expanded(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: isArabic ? screenWidth : screenWidth * 2,
                    child: Text(
                      translatedHadith,
                      style: TextStyle(
                        fontSize: 62,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                          shadows: kAfterAdhanTextShadow
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
