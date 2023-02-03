import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

import '../../../../generated/l10n.dart';
import '../../../helpers/StringUtils.dart';
import '../../../helpers/mawaqit_icons_icons.dart';
import '../../../themes/UIShadows.dart';

class SalahInWidget extends StatelessWidget {
  const SalahInWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.read<MosqueManager>();
    final nextSalahTime = mosqueManager.nextSalahAfter();

    String countDownText = [
      "${mosqueManager.salahName(mosqueManager.nextSalahIndex())} ${S.of(context).in1} ",
      if (nextSalahTime.inMinutes > 0)
        "${nextSalahTime.inHours.toString().padLeft(2, '0')}:${(nextSalahTime.inMinutes % 60).toString().padLeft(2, '0')}",
      if (nextSalahTime.inMinutes == 0)
        "${(nextSalahTime.inSeconds % 60).toString().padLeft(2, '0')} Sec",
    ].join();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          MawaqitIcons.icon_adhan,
          color: Colors.white,
          size: 2.3.vw,
        ),
        Container(
          constraints: BoxConstraints(maxWidth: 30.vw),
          padding: EdgeInsets.symmetric(
            horizontal: 1.45.vw,
          ),
          child: FittedBox(
            child: !mosqueManager.isShurukTime()
                ? Text(
                    countDownText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 2.8.vw,
                      // height: 2,
                      color: Colors.white,
                      fontFamily:
                          StringManager.getFontFamilyByString(countDownText),
                      shadows: kHomeTextShadow,
                    ),
                  )
                : Text(
                    mosqueManager.getShurukInString(context),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 2.8.vw,
                      // height: 2,
                      color: Colors.white,
                      fontFamily: StringManager.getFontFamilyByString(
                          mosqueManager.getShurukInString(context)),
                      shadows: kHomeTextShadow,
                    ),
                  ),
          ),
        ),
        Icon(
          MawaqitIcons.icon_adhan,
          color: Colors.white,
          size: 2.3.vw,
        ),
      ],
    );
  }
}
