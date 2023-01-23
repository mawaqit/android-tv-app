import 'package:flutter/material.dart';
import 'package:intl/intl.dart'hide TextDirection;
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/pages/home/widgets/SalahItem.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';

import '../../../../generated/l10n.dart';
import '../../../helpers/StringUtils.dart';

class AboveSalahBar extends StatelessWidget {
  const AboveSalahBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final mosqueManager = context.watch<MosqueManager>();
   final is12Hours =mosqueManager.mosqueConfig?.timeDisplayFormat == "12";
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

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: (size.width - 5 * kSalahItemWidgetWidth) / 8, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 8.vh,
                  alignment: Alignment.center,
                  padding: isArabic
                      ? EdgeInsets.symmetric(horizontal: 3.vh,)
                      : EdgeInsets.symmetric(horizontal: 2.5.vw, ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color:  Colors.black.withOpacity(.7),
                  ),
                  child: Text(
                    [
                      "${mosqueManager.salahName(mosqueManager.nextSalahIndex())} ${S.of(context).in1} ",
                      if (nextSalahTime.inMinutes > 0)
                        "${nextSalahTime.inHours.toString().padLeft(2, '0')}:${(nextSalahTime.inMinutes % 60).toString().padLeft(2, '0')}",
                      if (nextSalahTime.inMinutes == 0)
                        "${(nextSalahTime.inSeconds % 60).toString().padLeft(2, '0')} Sec",
                    ].join(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                      shadows: kHomeTextShadow,
                      fontFamily: StringManager.getFontFamily(context),
                        ),
                  ),
                ),
                Container(
                  height: 8.vh,
                  alignment: Alignment.center,

                  padding: isArabic
                      ? EdgeInsets.symmetric(horizontal: 3.vh  , )
                      : EdgeInsets.symmetric(horizontal: 2.5.vw, ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black.withOpacity(.7),
                  ),
                  child: Text(
                    textDirection: TextDirection.ltr,
                    is12Hours?DateFormat("HH:mm a", "en").format(now):DateFormat("HH:mm", "en").format(now),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      shadows: kHomeTextShadow,
                      color: Colors.white,

                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
