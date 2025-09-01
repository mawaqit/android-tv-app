import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_ar.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/pages/home/widgets/AboveSalahBar.dart';
import 'package:mawaqit/src/widgets/display_text_widget.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/responsive_mini_salah_bar_widget.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

import '../../../const/constants.dart';
import '../widgets/salah_items/responsive_mini_salah_bar_turkish_widget.dart';

class AzkarLists {
  static List<String> getAfterAsrList(AppLocalizations tr) => [
        tr.azkarList7,
        tr.azkarList10,
        tr.azkarList11,
        tr.azkarList12,
        tr.azkarList13,
        tr.azkarList14,
      ];

  static List<String> getAfterFajrList(AppLocalizations tr) => [
        tr.azkarList7,
        tr.azkarList8,
        tr.azkarList9,
        tr.azkarList10,
        tr.azkarList11,
        tr.azkarList12,
        tr.azkarList13,
      ];

  static List<String> getRegularList(AppLocalizations tr) => [
        tr.azkarList0, // أَسْـتَغْفِرُ الله، أَسْـتَغْفِرُ الله، أَسْـتَغْفِرُ الله
        tr.azkarList1, // سُـبْحانَ اللهِ، والحَمْـدُ لله، واللهُ أكْـبَر 33
        tr.azkarList4, // قُلۡ هُوَ ٱللَّهُ أَحَدٌ
        tr.azkarList3, // قُلۡ أَعُوذُ بِرَبِّ ٱلۡفَلَقِ
        tr.azkarList2, // قُلۡ أَعُوذُ بِرَبِّ ٱلنَّاسِ
        tr.azkarList5, // ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلۡحَيُّ ٱلۡقَيُّومُۚ لَا تَأۡخُذُهُۥ سِنَةٞ وَلَا نَوۡمٞۚ
        tr.azkarList6, // لا إِلَٰهَ إلاّ اللّهُ وحدَهُ لا شريكَ لهُ، لهُ المُـلْكُ ولهُ الحَمْد
      ];
}

class AfterSalahAzkar extends StatefulWidget {
  AfterSalahAzkar({
    Key? key,
    this.onDone,
    this.azkarTitle = AzkarConstant.kAzkarAfterPrayer,
    this.isAfterAsrOrFajr = false,
    this.isAfterAsr = false,
  }) : super(key: key);

  final VoidCallback? onDone;
  final String azkarTitle;
  final bool isAfterAsrOrFajr;
  final bool isAfterAsr;
  @override
  State<AfterSalahAzkar> createState() => _AfterSalahAzkarState();
}

class _AfterSalahAzkarState extends State<AfterSalahAzkar> {
  int activeHadith = 0;

  final arabicLocal = AppLocalizationsAr();

  String getItem(AppLocalizations tr, int index) {
    if (!widget.isAfterAsrOrFajr) {
      return AzkarLists.getRegularList(tr)[index % 7];
    }

    final list = widget.isAfterAsr ? AzkarLists.getAfterAsrList(tr) : AzkarLists.getAfterFajrList(tr);

    return list[index % list.length];
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
          image: AssetImage(R.ASSETS_BACKGROUNDS_ISLAMIC_CONTENT_BACKGROUND_WEBP),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 10),
          AboveSalahBar(),
          Expanded(
            child: DisplayTextWidget(
              title: widget.azkarTitle,
              arabicText: arabicHadith,
              translatedText: widget.isAfterAsrOrFajr ? null : translatedHadith,
            ),
          ),
          mosqueProvider.times!.isTurki ? ResponsiveMiniSalahBarTurkishWidget() : ResponsiveMiniSalahBarWidget(),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
