import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/pages/home/widgets/SalahItem.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';

import '../../../../i18n/l10n.dart';
import '../../../helpers/StringUtils.dart';
import '../../../widgets/TimePeriodWidget.dart';

class AboveSalahBar extends StatelessWidget {
  const AboveSalahBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final mosqueManager = context.watch<MosqueManager>();
    final is12Hours = mosqueManager.mosqueConfig?.timeDisplayFormat == "12";

    return StreamBuilder(
        stream: Stream.periodic(Duration(seconds: 1)),
        builder: (context, snapshot) {
          final now = mosqueManager.mosqueDate();

          final nextSalahIndex = mosqueManager.nextSalahIndex();
          var nextSalahTime = mosqueManager.actualTimes()[nextSalahIndex].difference(now);
          final isArabic = context.read<AppLanguage>().isArabic();
          // in case of fajr of the next day
          if (nextSalahTime < Duration.zero) {
            nextSalahTime = nextSalahTime + Duration(days: 1);
          }
          String countDownText = [
            "${mosqueManager.salahName(mosqueManager.nextSalahIndex())} ${S.of(context).in1} ",
            if (nextSalahTime.inMinutes > 0)
              "${nextSalahTime.inHours.toString().padLeft(2, '0')}:${(nextSalahTime.inMinutes % 60).toString().padLeft(2, '0')}",
            if (nextSalahTime.inMinutes == 0)
              "${(nextSalahTime.inSeconds % 60).toString().padLeft(2, '0')} Sec",
          ].join();
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: (size.width - 5 * kSalahItemWidgetWidth) / 8, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  clipBehavior: Clip.hardEdge,
                  height: 9.vh,
                  alignment: Alignment.center,
                  padding: isArabic
                      ? EdgeInsets.symmetric(
                    horizontal: 3.vh,
                  )
                      : EdgeInsets.symmetric(
                    horizontal: 2.5.vw,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: mosqueManager.getColorTheme().withOpacity(.7),
                  ),
                  child: Text(
                    countDownText,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      shadows: kHomeTextShadow,
                      fontSize: isArabic ? 5.3.vh : 6.vh,
                      fontFamily: StringManager.getFontFamilyByString(countDownText),
                    ),
                  ),
                ),
                Container(
                  height: 9.vh,
                  alignment: Alignment.center,
                  padding: isArabic
                      ? EdgeInsets.symmetric(
                    horizontal: 3.vh,
                  )
                      : EdgeInsets.symmetric(
                    horizontal: 2.5.vw,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: mosqueManager.getColorTheme().withOpacity(.7),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        textDirection: TextDirection.ltr,
                        is12Hours ? DateFormat("hh:mm", "en").format(now) : DateFormat("HH:mm", "en").format(now),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            shadows: kHomeTextShadow,
                            fontSize: isArabic ? 5.3.vh : 6.vh,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: isArabic?5:0,),
                      if (is12Hours)
                        SizedBox(
                          width: 2.6.vw,
                          child: TimePeriodWidget(
                            dateTime: now,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              shadows: kHomeTextShadow,
                              letterSpacing: 1.vw,
                              height: .9,
                              fontSize: 1.2.vw,
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}
