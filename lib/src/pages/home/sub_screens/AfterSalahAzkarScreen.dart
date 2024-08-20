import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_ar.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/pages/home/widgets/AboveSalahBar.dart';
import 'package:mawaqit/src/pages/home/widgets/HadithScreen.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/responsive_mini_salah_bar_widget.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

import '../../../const/constants.dart';
import '../widgets/salah_items/responsive_mini_salah_bar_turkish_widget.dart';

class AfterSalahAzkar extends StatefulWidget {
  AfterSalahAzkar({
    Key? key,
    this.onDone,
    this.azkarTitle = AzkarConstant.kAzkarAfterPrayer,
    this.isAfterAsrOrFajr = false,
  }) : super(key: key);

  final VoidCallback? onDone;
  final String azkarTitle;
  final bool isAfterAsrOrFajr;
  @override
  State<AfterSalahAzkar> createState() => _AfterSalahAzkarState();
}

class _AfterSalahAzkarState extends State<AfterSalahAzkar> {
  int activeHadith = 0;

  final arabicLocal = AppLocalizationsAr();

  String getItem(AppLocalizations tr, int index) {
    return widget.isAfterAsrOrFajr
        ? [
            tr.azkarList7,
            tr.azkarList8,
            tr.azkarList9,
            tr.azkarList10,
            tr.azkarList11,
            tr.azkarList12,
            tr.azkarList13,
          ][index % 7]
        : [
            // أَسْـتَغْفِرُ الله، أَسْـتَغْفِرُ الله، أَسْـتَغْفِرُ الله
            tr.azkarList0,

            // سُـبْحانَ اللهِ، والحَمْـدُ لله، واللهُ أكْـبَر 33
            tr.azkarList1,
            // قُلۡ هُوَ ٱللَّهُ أَحَدٌ
            tr.azkarList4,

            // قُلۡ أَعُوذُ بِرَبِّ ٱلۡفَلَقِ
            tr.azkarList3,

            // قُلۡ أَعُوذُ بِرَبِّ ٱلنَّاسِ
            tr.azkarList2,

            //ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلۡحَيُّ ٱلۡقَيُّومُۚ لَا تَأۡخُذُهُۥ سِنَةٞ وَلَا نَوۡمٞۚ
            tr.azkarList5,

            // لا إِلَٰهَ إلاّ اللّهُ وحدَهُ لا شريكَ لهُ، لهُ المُـلْكُ ولهُ الحَمْد
            tr.azkarList6,
          ][index % 7];
  }

  String arabicItem(int index) => getItem(arabicLocal, index);

  String translatedItem(int index) => getItem(S.of(context), index);

  @override
  void initState() {
    final mosqueManager = context.read<MosqueManager>();

    if (mosqueManager.mosqueConfig?.duaAfterPrayerEnabled == false)
      Future.delayed(Duration(milliseconds: 80), widget.onDone);
    else
      Future.delayed(kAzkarDuration, widget.onDone);

    Stream.periodic(Duration(seconds: 20), (x) => x).listen((event) {
      if (!mounted) return;
      setState(() => activeHadith++);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final translatedHadith = translatedItem(activeHadith);
    final arabicHadith = arabicItem(activeHadith);
    final mosqueProvider = context.read<MosqueManager>();

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(kBackgroundAdhkar),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 10),
          AboveSalahBar(),
          Expanded(
            child: HadithWidget(
              title: widget.azkarTitle,
              arabicText: arabicHadith,
              translatedText: translatedHadith,
            ),
          ),
          mosqueProvider.times!.isTurki ? ResponsiveMiniSalahBarTurkishWidget() : ResponsiveMiniSalahBarWidget(),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
