import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_ar.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/repaint_boundaries.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';

import '../../../helpers/StringUtils.dart';

class JumuaHadithSubScreen extends StatelessWidget {
  const JumuaHadithSubScreen({Key? key, this.onDone}) : super(key: key);

  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    final mosqueConfig = context.read<MosqueManager>().mosqueConfig;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final tr = S.of(context);
    final jumuaTimeStartedAr = tr.jumuaaScreenTitle;
    final jumuaArHadith = AppLocalizationsAr().jumuaaHadith;

    if (mosqueConfig!.jumuaDhikrReminderEnabled!) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          Container(
            child: Text(
              jumuaTimeStartedAr,
              style: TextStyle(
                  fontSize: 6.2.vw,
                  fontWeight: FontWeight.bold,
                  fontFamily:
                      StringManager.getFontFamilyByString(jumuaTimeStartedAr),
                  color: Colors.white,
                  shadows: kAfterAdhanTextShadow),
            )
                .animate()
                .slideY()
                .fade()
                .addRepaintBoundary(),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: AutoSizeText(
              jumuaArHadith,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 6.2.vw,
                  fontWeight: FontWeight.bold,
                  fontFamily: StringManager.fontFamilyKufi,
                  color: Colors.white,
                  shadows: kAfterAdhanTextShadow),
            ).animate().slideX(delay: .2.seconds).fade().addRepaintBoundary(),
          ),
          if (!isArabic)
            Flexible(
              fit: FlexFit.loose,
              child: AutoSizeText(
                tr.jumuaaHadith,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 3.vw,
                    fontFamily:
                        StringManager.getFontFamilyByString(tr.jumuaaHadith),
                    shadows: kAfterAdhanTextShadow),
              )
                  .animate()
                  .slideY(begin: 1, delay: .5.seconds)
                  .fade()
                  .addRepaintBoundary(),
            ),
          SizedBox(height: 20),
        ],
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
    );
  }
}
