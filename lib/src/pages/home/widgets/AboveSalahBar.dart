import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:mawaqit/src/widgets/time_widget.dart';
import 'package:provider/provider.dart';

import '../../../../i18n/l10n.dart';

class AboveSalahBar extends StatelessWidget {
  const AboveSalahBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.watch<MosqueManager>();
    final is12Hours = mosqueManager.mosqueConfig?.timeDisplayFormat == "12";

    return StreamBuilder(
        stream: Stream.periodic(Duration(seconds: 1)),
        builder: (context, snapshot) {
          var nextSalahTime = mosqueManager.nextSalahAfter();

          final now = mosqueManager.mosqueDate();

          String countDownText = [
            "${mosqueManager.salahName(mosqueManager.nextSalahIndex())} ${S.of(context).in1} ",
            if (nextSalahTime.inMinutes > 0)
              "${nextSalahTime.inHours.toString().padLeft(2, '0')}:${(nextSalahTime.inMinutes % 60).toString().padLeft(2, '0')}",
            if (nextSalahTime.inMinutes == 0) "${(nextSalahTime.inSeconds % 60).toString().padLeft(2, '0')} Sec",
          ].join();

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.vw, vertical: 1.vw),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    clipBehavior: Clip.hardEdge,
                    padding: EdgeInsets.symmetric(horizontal: 3.vw, vertical: 1.vw),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: mosqueManager.getColorTheme().withOpacity(.7),
                    ),
                    child: Text(
                      mosqueManager.isShurukTime ? mosqueManager.getShurukInString(context) : countDownText,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            shadows: kHomeTextShadow,
                            fontSize: 6.vr,
                          ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.vw, vertical: 1.vw),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: mosqueManager.getColorTheme().withOpacity(.7),
                    ),
                    child: TimeWidget.fromDate(
                      dateTime: now,
                      show24hFormat: !is12Hours,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            shadows: kHomeTextShadow,
                            fontSize: 6.vr,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  // child: Row(
                  //   mainAxisSize: MainAxisSize.min,
                  //   children: [
                  //     Text(
                  //       textDirection: TextDirection.ltr,
                  //       is12Hours ? DateFormat("hh:mm", "en").format(now) : DateFormat("HH:mm", "en").format(now),
                  //       style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  //           shadows: kHomeTextShadow,
                  //           fontSize: isArabic ? 5.3.vr : 6.vr,
                  //           color: Colors.white,
                  //           fontWeight: FontWeight.bold),
                  //     ),
                  //     SizedBox(width: isArabic ? 5 : 0),
                  //     if (is12Hours)
                  //       SizedBox(
                  //         width: 2.6.vr,
                  //         child: TimePeriodWidget(
                  //           dateTime: now,
                  //           style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  //                 shadows: kHomeTextShadow,
                  //                 letterSpacing: 1.vr,
                  //                 height: .9,
                  //                 color: Colors.white,
                  //                 fontWeight: FontWeight.w500,
                  //               ),
                  //         ),
                  //       ),
                  //   ],
                  // ),
                ],
              ),
            ),
          );
        });
  }
}
