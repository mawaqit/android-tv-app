import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/StringUtils.dart';
import 'package:mawaqit/src/helpers/repaint_boundaries.dart';
import 'package:mawaqit/src/pages/home/widgets/FlashAnimation.dart';
import 'package:mawaqit/src/services/audio_manager.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';

class IqamaSubScreen extends StatefulWidget {
  const IqamaSubScreen({Key? key, this.onDone}) : super(key: key);

  final VoidCallback? onDone;

  @override
  State<IqamaSubScreen> createState() => _IqamaSubScreenState();
}

class _IqamaSubScreenState extends State<IqamaSubScreen> {
  AudioManager? audioManager;

  @override
  void initState() {
    final mosqueManager = context.read<MosqueManager>();
    final mosqueConfig = mosqueManager.mosqueConfig!;

    if (mosqueConfig.iqamaBip) {
      audioManager = context.read<AudioManager>();
      audioManager!.loadAndPlayIqamaBipVoice(mosqueManager.mosqueConfig);
    }
    super.initState();
  }

  @override
  void dispose() {
    audioManager?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tr = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            tr.iqama,
            style: theme.textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              shadows: kAfterAdhanTextShadow,
              fontFamily: StringManager.getFontFamilyByString(tr.alIqama),
            ),
            textAlign: TextAlign.center,
          ).animate().slide(begin: Offset(0, -1)).fade().addRepaintBoundary(),
        ),
        Expanded(
          child: FlashAnimation(
            child: SvgPicture.asset(
              R.ASSETS_SVG_NO_PHONE_SVG,
              width: 50.vr,
            ),
          ).animate().scale(delay: .2.seconds).addRepaintBoundary(),
        ),
        SizedBox(height: 15),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.vw, vertical: 2.vw),
          child: Text(
            tr.turnOfPhones,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 4.vwr,
              color: Colors.white,
              fontFamily: StringManager.getFontFamilyByString(tr.turnOfPhones),
              shadows: kAfterAdhanTextShadow,
            ),
          ).animate().slide(begin: Offset(0, 1)).fade().addRepaintBoundary(),
        ),
        SizedBox(height: 30),
      ],
    );
  }
}
