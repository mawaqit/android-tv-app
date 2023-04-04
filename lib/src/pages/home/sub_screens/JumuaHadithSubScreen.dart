import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_ar.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/repaint_boundaries.dart';
import 'package:mawaqit/src/pages/home/widgets/AboveSalahBar.dart';
import 'package:mawaqit/src/pages/home/widgets/HadithScreen.dart';
import 'package:mawaqit/src/pages/home/widgets/SalahTimesBar.dart';
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
    final tr = S.of(context);
    final jumuaArHadith = AppLocalizationsAr().jumuaaHadith;

    if (!mosqueConfig!.jumuaDhikrReminderEnabled!) return Scaffold(backgroundColor: Colors.black);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: AboveSalahBar(),
        ),
        Expanded(
          child: HadithWidget(
            title: tr.jumuaaScreenTitle,
            arabicText: jumuaArHadith,
            translatedText: tr.jumuaaHadith,
            mainAxisAlignment: MainAxisAlignment.start,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: SalahTimesBar(microStyle: true, miniStyle: true, activeItem: 1),
        ),
      ],
    );
  }
}
