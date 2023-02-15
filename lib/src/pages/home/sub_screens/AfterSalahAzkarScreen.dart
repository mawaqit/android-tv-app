import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/StringUtils.dart';
import 'package:mawaqit/src/helpers/repaint_boundires.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../themes/UIShadows.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_ar.dart';

class AfterSalahAzkar extends StatefulWidget {
  AfterSalahAzkar({Key? key, this.onDone}) : super(key: key);

  final VoidCallback? onDone;

  @override
  State<AfterSalahAzkar> createState() => _AfterSalahAzkarState();
}

class _AfterSalahAzkarState extends State<AfterSalahAzkar> {
  /// the item duration in seconds
  final itemDuration = kAzkarDuration.inMinutes / 7 * 60;

  final azkarTitle = 'أذكار بعد الصلاة';

  final arabicLocal = AppLocalizationsAr();

  String arabicItem(int index) {
    switch (index) {
      case 0:
        return arabicLocal.azkarList0;
      case 1:
        return arabicLocal.azkarList1;
      case 2:
        return arabicLocal.azkarList2;
      case 3:
        return arabicLocal.azkarList3;
      case 4:
        return arabicLocal.azkarList4;
      case 5:
        return arabicLocal.azkarList5;
      case 6:
        return arabicLocal.azkarList6;
      default:
        return '';
    }
  }

  String translatedItem(int index) {
    switch (index) {
      case 0:
        return S.of(context).azkarList0;
      case 1:
        return S.of(context).azkarList1;
      case 2:
        return S.of(context).azkarList2;
      case 3:
        return S.of(context).azkarList3;
      case 4:
        return S.of(context).azkarList4;
      case 5:
        return S.of(context).azkarList5;
      case 6:
        return S.of(context).azkarList6;
      default:
        return '';
    }
  }

  @override
  void initState() {
    if (context.read<MosqueManager>().mosqueConfig?.duaAfterPrayerEnabled ==
        false)
      Future.delayed(Duration(milliseconds: 80), widget.onDone);
    else
      Future.delayed(kAzkarDuration, widget.onDone);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final screenWidth = MediaQuery.of(context).size.width;

    return StreamBuilder<int>(
      stream: Stream.periodic(
          Duration(seconds: 1), (computationCount) => computationCount),
      builder: (context, snapshot) {
        final time = snapshot.data ?? 0;

        int activeHadith = (time ~/ itemDuration) % 7;

        final translatedHadith = translatedItem(activeHadith);
        final arabicHadith = arabicItem(activeHadith);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "$azkarTitle ${isArabic ? '' : '(${S.of(context).alAthkar})'}",
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontFamily: StringManager.fontFamilyKufi,
                  shadows: kAfterAdhanTextShadow),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ).animate().slide().fade().addRepaintBoundary(),
            FractionallySizedBox(
              widthFactor: .6,
              child: Divider(color: Colors.white),
            ),
            Expanded(
              child: Container(
                key: ValueKey(activeHadith),
                padding:
                    EdgeInsets.symmetric(horizontal: 1.2.vw, vertical: 1.vh),
                width: isArabic || translatedHadith.isEmpty
                    ? screenWidth
                    : screenWidth * 1.5,
                child: AutoSizeText(
                  arabicHadith,
                  style: TextStyle(
                    fontSize: 6.2.vw,
                    fontWeight: FontWeight.bold,
                    fontFamily:
                        StringManager.getFontFamilyByString(arabicHadith),
                    color: Colors.white,
                    shadows: kIqamaCountDownTextShadow,
                  ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: .3.seconds).addRepaintBoundary(),
              ),
            ),
            if (!isArabic && translatedHadith.isNotEmpty)
              Expanded(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: isArabic ? screenWidth : screenWidth * 2,
                    child: AutoSizeText(
                      stepGranularity: 1,
                      translatedHadith,
                      style: TextStyle(
                        fontSize: 6.2.vw,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: kAfterAdhanTextShadow,
                        fontFamily: StringManager.getFontFamilyByString(
                          translatedHadith,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
