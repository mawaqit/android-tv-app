import 'package:flutter/material.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

import '../../../helpers/StringUtils.dart';
import '../../../helpers/mawaqit_icons_icons.dart';
import '../../../themes/UIShadows.dart';

class SalahInWidget extends StatelessWidget {
  const SalahInWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.read<MosqueManager>();
    final nextSalahTime = mosqueManager.nextSalahAfter();

    var nextSalahIndex = mosqueManager.nextSalahIndex();
    var nextSalahName = mosqueManager.salahName(nextSalahIndex);

    if (nextSalahIndex == 1 && mosqueManager.mosqueDate().weekday == DateTime.friday && mosqueManager.typeIsMosque) {
      nextSalahName = S.of(context).jumua;
    }

    String countDownText = StringManager.getCountDownText(
      context,
      nextSalahTime,
      nextSalahName,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          MawaqitIcons.icon_adhan,
          color: Colors.white,
          size: 2.3.vwr,
        ),
        Container(
          constraints: BoxConstraints(maxWidth: 30.vwr),
          padding: EdgeInsets.symmetric(
            horizontal: 1.45.vwr,
          ),
          child: FittedBox(
            child: !mosqueManager.isShurukTime
                ? Text(
                    countDownText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 2.8.vwr,
                      color: Colors.white,
                      fontFamily: StringManager.getFontFamilyByString(countDownText),
                      shadows: kHomeTextShadow,
                    ),
                  )
                : Text(
                    mosqueManager.getShurukInString(context),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 2.8.vwr,
                      // height: 2,
                      color: Colors.white,
                      fontFamily: StringManager.getFontFamilyByString(mosqueManager.getShurukInString(context)),
                      shadows: kHomeTextShadow,
                    ),
                  ),
          ),
        ),
        Icon(MawaqitIcons.icon_adhan, color: Colors.white, size: 2.3.vwr),
      ],
    );
  }
}
