import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/StringUtils.dart';
import 'package:mawaqit/src/helpers/mawaqit_icons_icons.dart';
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
    if (context.read<MosqueManager>().mosqueConfig!.iqamaBip) {
      audioManager = context.read<AudioManager>();
      audioManager!.loadAndPlayIqamaBipVoice(
        context.read<MosqueManager>().mosqueConfig,
        onDone: widget.onDone,
      );
    } else {
      Future.delayed(Duration(minutes: 1), widget.onDone);
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
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              height: 30.vh,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 4.vw),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment(0, 0),
                  end: Alignment(0, 1),
                  colors: [
                    theme.primaryColor,
                    theme.primaryColor.withOpacity(0),
                  ],
                ),
              ),
              child: Text(
                tr.alIqama,
                style: theme.textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    shadows: kAfterAdhanTextShadow,
                    fontFamily:
                        StringManager.getFontFamilyByString(tr.alIqama)),
              ),
            ),
          ),
        ),
        Expanded(
            child: FlashAnimation(
          child: Stack(children: [
            Transform.scale(
                scaleX: 1.01,
                scaleY: 1.02,
                child: Image.asset(
                  R.ASSETS_ICON_NO_PHONE_PNG,
                  color: Colors.black38,
                )),
            Image.asset(
              R.ASSETS_ICON_NO_PHONE_PNG,
              color: Colors.white,
            ),
          ]),
        )),
        Text(
          tr.turnOfPhones,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 4.vw,
            color: Colors.white,
            fontFamily: StringManager.getFontFamilyByString(tr.turnOfPhones),
            shadows: kAfterAdhanTextShadow,
          ),
        ),
        SizedBox(height: 50),
      ],
    );
  }
}
