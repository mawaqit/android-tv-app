import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

import '../../../../generated/l10n.dart';
import '../../../helpers/StringUtils.dart';
import '../../../helpers/mawaqit_icons_icons.dart';
import '../../../themes/UIShadows.dart';


class SalahInWidget extends StatelessWidget {
  final double adhanIconSize ;
  final Duration  nextSalahTime;
  const SalahInWidget({Key? key, required this.adhanIconSize, required this.nextSalahTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.read<MosqueManager>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          MawaqitIcons.icon_adhan,
          color: Colors.white,
          size: adhanIconSize,
        ),
        Container(
          constraints: BoxConstraints(maxWidth:30.vw ),
          padding: EdgeInsets.symmetric(
            horizontal: 1.45.vw,
          ),
          child: FittedBox(
            child:!mosqueManager.isShurukTime()? Text(
              [
                "${mosqueManager.salahName(mosqueManager.nextSalahIndex())} ${ S.of(context).in1} ",
                if (nextSalahTime.inMinutes > 0)
                  "${nextSalahTime.inHours.toString().padLeft(2, '0')}:${(nextSalahTime.inMinutes % 60).toString().padLeft(2, '0')}",
                if (nextSalahTime.inMinutes == 0)
                  "${(nextSalahTime.inSeconds % 60).toString().padLeft(2, '0')} Sec",
              ].join() ,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 2.8.vw,
                // height: 2,
                color: Colors.white,
                fontFamily: StringManager.getFontFamily(context),
                shadows: kHomeTextShadow,
              ),
            ): Text(
           mosqueManager.getShurukInString(context),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 2.8.vw,
                // height: 2,
                color: Colors.white,
                fontFamily: StringManager.getFontFamily(context),
                shadows: kHomeTextShadow,
              ),
            ),
          ),
        ),
        Icon(
          MawaqitIcons.icon_adhan,
          color: Colors.white,
          size: adhanIconSize,
        ),
      ],
    );
  }
}
