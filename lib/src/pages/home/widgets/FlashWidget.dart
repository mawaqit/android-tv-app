import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:provider/provider.dart';
import '../../../helpers/HexColor.dart';
import '../../../services/mosque_manager.dart';
import '../../../themes/UIShadows.dart';

class FlashWidget extends StatefulWidget {
  const FlashWidget({Key? key}) : super(key: key);

  @override
  State<FlashWidget> createState() => _FlashWidgetState();
}

class _FlashWidgetState extends State<FlashWidget> {
  var enabled = true;
  late final Mosque mosque;

  @override
  void initState() {
    final mosqueProvider = context.read<MosqueManager>();
    mosque = mosqueProvider.mosque!;

    final startDate = DateTime.tryParse(mosque.flash?.startDate ?? 'x');
    final endDate = DateTime.tryParse(mosque.flash?.endDate ?? 'x');

    if (endDate != null) {
      final now = DateTime.now();
      final endOfDay =
          DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

      if (startDate != null) {
        final startOfDay =
            DateTime(startDate.year, startDate.month, startDate.day);
        enabled = now.isAfter(startOfDay) && now.isBefore(endOfDay);
      } else {
        enabled = now.isBefore(endOfDay);
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!enabled) return SizedBox();

    return RepaintBoundary(
      child: Marquee(
        key: ValueKey(mosque.flash?.content),
        textDirection: mosque.flash?.orientation == 'rtl'
            ? TextDirection.rtl
            : TextDirection.ltr,
        text: mosque.flash?.content ?? '',
        velocity: 90,
        blankSpace: 400,
        style: TextStyle(
          height: 1,
          fontSize: 3.4.vwr,
          fontWeight: FontWeight.bold,
          wordSpacing: 3,
          shadows: kHomeTextShadow,
          color: HexColor(mosque.flash?.color ?? "#FFFFFF"),
        ),
      ),
    );
  }
}
