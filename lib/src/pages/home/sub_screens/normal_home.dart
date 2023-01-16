import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:mawaqit/generated/l10n.dart';
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
import '../widgets/footer.dart';

class NormalHomeSubScreen extends StatelessWidget {
  const NormalHomeSubScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosqueProvider = context.read<MosqueManager>();
    final mosque = mosqueProvider.mosque!;
    final mosqueConfig = mosqueProvider.mosqueConfig;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            MosqueHeader(mosque: mosque),
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 2.vw, top: 1.5.vh),
                    child: ShurukWidget(),
                  ),
                  HomeTimeWidget(),
                  Padding(
                    padding: EdgeInsets.only(right: 5.7.vw, top: 1.3.vh),
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
            Padding(
              padding: EdgeInsets.only(top: 7.3.vh, right: 1.vw),
              child: SalahTimesBar(),
            ),
          ],
        ),
        mosqueConfig!.footer!
            ? Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  MosqueInformationWidget(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: .5.vw, vertical: .2.vw),
                    width: double.infinity,
                    color: mosque.flash?.content.isEmpty != false ? null : Colors.black38,
                    child: SizedBox(
                      height: 5.vw,
                      child: FlashWidget(),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: .4.vw, vertical: .2.vw),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ID ${mosque.id}",
                            style: TextStyle(
                              fontSize: .7.vw,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              shadows: kHomeTextShadow,
                            ),
                          ),
                          SizedBox(height: 5),
                          Image.network(
                            'https://mawaqit.net/static/images/store-qrcode.png?4.89.2',
                            width: 5.vw,
                            height: 5.vw,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 1.5.vh, left: 1.vw),
                      child: HomeLogoVersion(),
                    ),
                  ),
                ],
              )
            : SizedBox(
                height: 5.vw,
              )
      ],
    );
  }
}
