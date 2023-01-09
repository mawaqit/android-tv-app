import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';

const kSalahItemWidgetWidth = 135.0;

class SalahItemWidget extends StatelessWidget {
  SalahItemWidget({
    Key? key,
    required this.time,
    this.title,
    this.iqama,
    this.active = false,
    this.removeBackground = false,
    this.withDivider = true,
  }) : super(key: key);

  final String? title;
  final String time;
  final String? iqama;

  final bool withDivider;
  final bool active;
  final bool removeBackground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16.vw,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.vw),
        color: active
            ? Color(0x994e2b81)
            : removeBackground
                ? null
                : Colors.black.withOpacity(.70),
      ),
      padding: EdgeInsets.symmetric(vertical: 1.vw, horizontal: 2.vw),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            FittedBox(
              child: Text(
                title!,
                style: TextStyle(
                  fontSize: 3.vw,
                  shadows: kHomeTextShadow,
                  color: Colors.white,
                ),
              ),
            ),
          SizedBox(height: 10),
          Text(
            time,
            style: TextStyle(
              fontSize: 4.vw,
              fontWeight: FontWeight.w700,
              shadows: kHomeTextShadow,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 1.3.vw,
            width: double.infinity,
            child: Divider(thickness: 1, color: withDivider ? Colors.white : Colors.transparent),
          ),
          if (iqama != null)
            Text(
              '$iqama${iqama!.startsWith('+') ? "\'" : ""}',
              style: TextStyle(
                fontSize: 3.vw,
                fontWeight: FontWeight.bold,
                shadows: kHomeTextShadow,
                letterSpacing: 1,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}
