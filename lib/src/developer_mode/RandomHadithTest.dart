import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/Api.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/pages/home/widgets/AboveSalahBar.dart';
import 'package:mawaqit/src/pages/home/widgets/SalahTimesBar.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';

import '../helpers/StringUtils.dart';

// Center(
// child: Container(
// child: Text(
// style: TextStyle(
// fontSize: 62,
// color: Colors.white70,
// ),
// "No Announcement found",
// ),
// )),

class RandomHadithTest extends StatelessWidget {
  const RandomHadithTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.read<MosqueManager>();
    final mosqueConfig = mosqueManager.mosqueConfig;

    if (!mosqueConfig!.randomHadithEnabled) {
      return Center(
          child: Container(
        padding: EdgeInsets.all(2.5.vw),
        child: Text(
          style: TextStyle(fontSize: 62, color: Colors.white, shadows: kIqamaCountDownTextShadow),
          "Random Hadith is Disabled",
        ),
      ));
    }
    if (mosqueManager.isDisableHadithBetweenSalah()) {
      final twoSalahIndex = mosqueConfig.randomHadithIntervalDisabling!.split("-");
      int firstIndex = int.parse(twoSalahIndex.first);
      int lastIndex = int.parse(twoSalahIndex.last);
      return Center(
          child: Container(
        padding: EdgeInsets.all(2.5.vw),
        child: Text(
          style: TextStyle(fontSize: 62, color: Colors.white, shadows: kIqamaCountDownTextShadow),
          "No Random Hadith between ${mosqueManager.salahName(firstIndex)} and ${mosqueManager.salahName(lastIndex)}",
        ),
      ));
    }

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: AboveSalahBar(),
        ),
        Column(
          children: [
            SizedBox(
              height: 9.vh,
            ),
            Expanded(
              child: FutureBuilder<String>(
                future: Api.randomHadith(language: mosqueConfig.hadithLang!),
                builder: (context, snapshot) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: AutoSizeText(
                        snapshot.data?.padRight(500) ?? '',
                        stepGranularity: 12,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 100.vw,
                          fontWeight: FontWeight.bold,
                          shadows: kIqamaCountDownTextShadow,
                          fontFamily: mosqueConfig.hadithLang!.contains("ar") || mosqueConfig.hadithLang!.contains("ur")
                              ? StringManager.fontFamilyKufi
                              : null,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: .7.vh),
            SalahTimesBar(
              miniStyle: true,
              microStyle: true,
            ),
            SizedBox(height: 4.vh),
          ],
        ),
      ],
    );
  }
}
