import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marquee/marquee.dart';
import 'package:mawaqit/src/pages/home/widgets/HomeLogoVersion.dart';
import 'package:mawaqit/src/pages/home/widgets/SalahItem.dart';
import 'package:mawaqit/src/pages/home/widgets/TimeWidget.dart';
import 'package:mawaqit/src/pages/home/widgets/WeatherWidget.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';

class OfflineHomeScreen extends ConsumerWidget {
  const OfflineHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/backgrounds/splash_screen_5.png'), fit: BoxFit.cover),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildHeader(context),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(
                    child: SalahItemWidget(
                      title: "Imsak",
                      time: "12:00",
                      removeBackground: true,
                    ),
                  ),
                ),
                Expanded(
                  child: HomeTimeWidget(),
                ),
                Expanded(
                  child: Center(
                    child: SalahItemWidget(
                      title: "Jumua",
                      iqama: "12:34",
                      time: "12:00",
                      removeBackground: true,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SalahItemWidget(title: "Fajr", time: '06:28', iqama: "08:45", active: true, withDivider: false),
                SalahItemWidget(title: "Dhuhr", time: '06:28', iqama: "08:45", withDivider: false),
                SalahItemWidget(title: "Asr", time: '06:28', iqama: "08:45", withDivider: false),
                SalahItemWidget(title: "Maghrib", time: '06:28', iqama: "08:45", withDivider: false),
                SalahItemWidget(title: "Isha", time: '06:28', iqama: "08:45", withDivider: false),
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
                      Text(
                        "ID 1",
                        style: TextStyle(
                          fontSize: 7,
                          color: Colors.grey,
                          shadows: kHomeTextShadow,
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
                      child: Marquee(
                        text:
                            "Le message flash est un message éphémère, il est utilisé en général pour informer vos fidèles d'un événement important.",
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
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 5, backgroundColor: Colors.green),
              SizedBox(width: 5),
              Text("Offline"),
            ],
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/img/logo.png', width: 50, height: 50),
                Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: Text(
                    "Mosque Name",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          shadows: kHomeTextShadow,
                        ),
                  ),
                ),
                Image.asset('assets/img/logo.png', width: 50, height: 50),
              ],
            ),
          ),
          WeatherWidget(),
        ],
      ),
    );
  }
}
