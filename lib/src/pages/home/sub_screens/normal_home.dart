import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/pages/home/widgets/HomeLogoVersion.dart';
import 'package:mawaqit/src/pages/home/widgets/SalahItem.dart';
import 'package:mawaqit/src/pages/home/widgets/SalahTimesBar.dart';
import 'package:mawaqit/src/pages/home/widgets/ShurukWidget.dart';
import 'package:mawaqit/src/pages/home/widgets/TimeWidget.dart';
import 'package:mawaqit/src/pages/home/widgets/mosque_header.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';

import '../widgets/FlashWidget.dart';
import '../widgets/MosqueInformationWidget.dart';
import '../widgets/footer.dart';

class NormalHomeSubScreen extends StatelessWidget {
  const NormalHomeSubScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosqueProvider = context.read<MosqueManager>();
    final mosque = mosqueProvider.mosque!;
    final mosqueConfig = mosqueProvider.mosqueConfig;
    final isArabic = context.read<AppLanguage>().isArabic();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Directionality(textDirection: TextDirection.ltr, child: MosqueHeader(mosque: mosque)),
            Padding(
              padding: EdgeInsets.only(top: 1.vh),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  crossAxisAlignment: isArabic ? CrossAxisAlignment.center : CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding:
                      EdgeInsets.only(left: 2.vw,top: 1.5.vh),
                      // :EdgeInsets.only(left: 2.vw,bottom: 6.vh),
                      child: ShurukWidget(),
                    ),
                    HomeTimeWidget(),
                    Padding(
                      padding: isArabic
                          ? EdgeInsets.only(right: 5.7.vw, top: 1.3.vh)
                          : EdgeInsets.only(right: 5.7.vw, top: 2.vh),
                      child: Center(
                        child: SalahItemWidget(
                          title: S.of(context).jumua,
                          time: mosqueProvider.times!.jumua ?? "",
                          iqama: mosqueProvider.times!.jumua2,
                          active: mosqueProvider.nextSalahIndex() == 2 &&
                              mosqueProvider.mosqueDate().weekday == DateTime.friday,
                          removeBackground: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding:
             isArabic? EdgeInsets.only(top: 7.3.vh, right: 1.vw):
              EdgeInsets.only(top: 8.vh, right: 1.vw),
              child: SalahTimesBar(),
            ),
          ],
        ),
        Directionality(textDirection: TextDirection.ltr, child: Footer()),
      ],
    );
  }
}
