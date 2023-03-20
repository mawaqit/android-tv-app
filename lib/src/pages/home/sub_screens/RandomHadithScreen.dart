import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/src/helpers/Api.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/repaint_boundaries.dart';
import 'package:mawaqit/src/pages/home/widgets/AboveSalahBar.dart';
import 'package:mawaqit/src/pages/home/widgets/SalahTimesBar.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';

import '../../../helpers/StringUtils.dart';
import '../../../services/mosque_manager.dart';

class RandomHadithScreen extends StatefulWidget {
  const RandomHadithScreen({Key? key}) : super(key: key);

  @override
  State<RandomHadithScreen> createState() => _RandomHadithScreenState();
}

class _RandomHadithScreenState extends State<RandomHadithScreen> {
  String? hadith;

  @override
  void initState() {
    final mosqueManager = context.read<MosqueManager>();
    final mosqueConfig = mosqueManager.mosqueConfig;

    Api.randomHadith(language: mosqueConfig!.hadithLang!)
        .then((value) => setState(() => hadith = value));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.watch<MosqueManager>();
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: AboveSalahBar(),
        ),
        Expanded(
          child: RepaintBoundary(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: AutoSizeText(
                hadith ?? '',
                textAlign: TextAlign.center,
                textDirection: StringManager.getTextDirectionOfLocal(
                  Locale(mosqueManager.mosqueConfig!.hadithLang ?? 'en'),
                ),
                style: TextStyle(
                  fontSize: 100.vw,
                  fontWeight: FontWeight.bold,
                  shadows: kIqamaCountDownTextShadow,
                  fontFamily: StringManager.getFontFamilyByString(
                    hadith ?? '',
                  ),
                  color: Colors.white,
                ),
              ),
            )
                .animate(target: hadith == null ? 0 : 1)
                .fadeIn()
                .addRepaintBoundary(),
          ),
        ),
        SalahTimesBar(
          miniStyle: true,
          microStyle: true,
        ),
        SizedBox(height: 4.vh),
      ],
    );
  }
}
