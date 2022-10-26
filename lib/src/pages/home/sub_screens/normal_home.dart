import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/src/pages/home/widgets/HomeLogoVersion.dart';
import 'package:mawaqit/src/pages/home/widgets/SalahItem.dart';
import 'package:mawaqit/src/pages/home/widgets/TimeWidget.dart';
import 'package:mawaqit/src/pages/home/widgets/mosque_header.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';

class NormalHomeSubScreen extends StatelessWidget {
  const NormalHomeSubScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosqueProvider = context.read<MosqueManager>();
    final mosque = mosqueProvider.mosque!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MosqueHeader(mosque: mosque),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: SalahItemWidget(
                  title: S.of(context).imsak,
                  time: mosqueProvider.imsak,
                  removeBackground: true,
                  withDivider: false,
                ),
              ),
            ),
            Expanded(child: HomeTimeWidget()),
            Expanded(
              child: Center(
                child: SalahItemWidget(
                  title: S.of(context).jumua,
                  time: mosqueProvider.times!.jumua,
                  iqama: mosqueProvider.times!.jumua2,
                  active:
                      mosqueProvider.nextSalahIndex() == 2 && mosqueProvider.mosqueDate().weekday == DateTime.friday,
                  removeBackground: true,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SalahItemWidget(
              title: S.of(context).fajr,
              time: mosqueProvider.todayTimes[0],
              iqama: mosqueProvider.todayIqama[0],
              active: mosqueProvider.nextSalahIndex() == 1,
              withDivider: false,
            ),
            SalahItemWidget(
              title: S.of(context).duhr,
              time: mosqueProvider.todayTimes[1],
              iqama: mosqueProvider.todayIqama[1],
              active: mosqueProvider.nextSalahIndex() == 2,
              withDivider: false,
            ),
            SalahItemWidget(
              title: S.of(context).asr,
              time: mosqueProvider.todayTimes[2],
              iqama: mosqueProvider.todayIqama[2],
              active: mosqueProvider.nextSalahIndex() == 3,
              withDivider: false,
            ),
            SalahItemWidget(
              title: S.of(context).maghrib,
              time: mosqueProvider.todayTimes[3],
              iqama: mosqueProvider.todayIqama[3],
              active: mosqueProvider.nextSalahIndex() == 4,
              withDivider: false,
            ),
            SalahItemWidget(
              title: S.of(context).isha,
              time: mosqueProvider.todayTimes[4],
              iqama: mosqueProvider.todayIqama[4],
              active: mosqueProvider.nextSalahIndex() == 0,
              withDivider: false,
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.all(2),
          width: double.infinity,
          color: Colors.black38,
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Text(
                      "ID ${mosque.id}",
                      style: TextStyle(
                        fontSize: 7,
                        color: Colors.grey,
                        shadows: kHomeTextShadow,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Image.network(
                    'https://mawaqit.net/static/images/store-qrcode.png?4.89.2',
                    width: 40,
                    height: 40,
                  ),
                ],
              ),
              Expanded(
                child: SizedBox(
                  height: 60,
                  child: mosque.flash?.content.isEmpty != false
                      ? null
                      : Marquee(
                          text: mosque.flash?.content ?? '',
                          scrollAxis: Axis.horizontal,
                          blankSpace: 500,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            wordSpacing: 3,
                            shadows: kHomeTextShadow,
                          ),
                        ),
                ),
              ),
              HomeLogoVersion(),
            ],
          ),
        ),
      ],
    );
  }
}
