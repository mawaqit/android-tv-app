import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:provider/provider.dart';

import '../../../helpers/HexColor.dart';
import '../../../services/mosque_manager.dart';
import '../../../themes/UIShadows.dart';

class FlashWidget extends StatelessWidget {
  const FlashWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosqueProvider = context.read<MosqueManager>();
    final mosque = mosqueProvider.mosque!;
    final now = DateTime.now();
    DateTime? startDate;
    DateTime? endDate;
    if (startDate != null) startDate = DateTime.parse(mosque.flash!.startDate!);
    if (endDate != null) startDate = DateTime.parse(mosque.flash!.endDate!);
    bool flashIsInDateTime = now.isAfter(startDate ?? now) && now.isBefore(endDate ?? now);
    bool isNoDate = mosque.flash?.startDate == null || mosque.flash?.endDate == null;
    return mosque.flash?.content.isEmpty != false || (!flashIsInDateTime && !isNoDate)
        //todo get the message
        ? SizedBox()
        : Marquee(
            velocity:90,
            decelerationCurve: Curves.linear,
            accelerationCurve: Curves.linear,
            text: mosque.flash?.content ?? '',
            scrollAxis: Axis.horizontal,
            blankSpace: 500,
            style: TextStyle(
              fontSize:3.4.vw,
              fontWeight: FontWeight.bold,
              wordSpacing: 3,
              shadows: kHomeTextShadow,
              color: HexColor(mosque.flash?.color ?? "#FFFFFF"),
            ),
          );
  }
}
