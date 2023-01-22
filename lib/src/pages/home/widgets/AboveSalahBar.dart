import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/pages/home/widgets/SalahItem.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

import '../../../../generated/l10n.dart';
import '../../../helpers/StringUtils.dart';

class AboveSalahBar extends StatelessWidget {
  const AboveSalahBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final mosqueManager = context.watch<MosqueManager>();

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
            padding: EdgeInsets.symmetric(horizontal: (size.width - 5 * kSalahItemWidgetWidth) / 6,vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                  isArabic?EdgeInsets.symmetric(horizontal: 20, vertical: 3):
                  EdgeInsets.symmetric(horizontal: 2.5.vw, vertical: 1.vh),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: mosqueManager.getColorTheme().withOpacity(.70),
                  ),
                  child: Text(
                    [
                      "${mosqueManager.salahName(mosqueManager.nextSalahIndex())} ${S.of(context).in1} ",
                      if (nextSalahTime.inMinutes > 0)
                        "${nextSalahTime.inHours.toString().padLeft(2, '0')}:${(nextSalahTime.inMinutes % 60).toString().padLeft(2, '0')}",
                      if (nextSalahTime.inMinutes == 0)
                        "${(nextSalahTime.inSeconds % 60).toString().padLeft(2, '0')} Sec",
                    ].join(),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.white, fontFamily: StringManager.getFontFamily(context)),
                  ),
                ),
                Container(
                  padding: isArabic?EdgeInsets.symmetric(horizontal: 20, vertical: 3):
                  EdgeInsets.symmetric(horizontal: 2.5.vw, vertical: 1.vh),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: mosqueManager.getColorTheme().withOpacity(.70),
                  ),
                  child: Text(
                    DateFormat("HH:mm", "en").format(now),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.white, fontFamily: StringManager.getFontFamily(context)),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
