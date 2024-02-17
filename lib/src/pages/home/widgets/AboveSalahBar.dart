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
            "${mosqueManager.getSalahNameByIndex(
              mosqueManager.nextSalahIndex(),
              context,
            )} ${S.of(context).in1} ",
            if (nextSalahTime.inMinutes > 0)
              "${nextSalahTime.inHours.toString().padLeft(2, '0')}:${(nextSalahTime.inMinutes % 60).toString().padLeft(2, '0')}",
            if (nextSalahTime.inMinutes == 0) "${(nextSalahTime.inSeconds % 60).toString().padLeft(2, '0')} Sec",
          ].join();

          return Container(
            padding: EdgeInsets.symmetric(horizontal: 2.vwr),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  clipBehavior: Clip.hardEdge,
                  padding: EdgeInsets.symmetric(horizontal: 2.vw, vertical: .5.vwr),
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
                          height: 1,
                        ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.vw, vertical: .5.vwr),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: mosqueManager.getColorTheme().withOpacity(.7),
                  ),
                  child: TimeWidget.fromDate(
                    dateTime: now,
                    show24hFormat: !is12Hours,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(shadows: kHomeTextShadow, fontSize: 6.vr, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
