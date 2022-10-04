import 'package:flutter/material.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';

class SalahItemWidget extends StatelessWidget {
  SalahItemWidget({
    Key? key,
    required this.title,
    required this.time,
    this.iqama,
    this.active = false,
    this.removeBackground = false,
    this.withDivider = true,
  }) : super(key: key);

  final String title;
  final String time;
  final String? iqama;

  final bool withDivider;
  final bool active;
  final bool removeBackground;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: active
            ? Color(0x994e2b81)
            : removeBackground
                ? null
                : Colors.black45,
      ),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 24, shadows: kHomeTextShadow),
          ),
          SizedBox(height: 10),
          Text(
            time,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              shadows: kHomeTextShadow,
            ),
          ),
          Container(
            height: .7,
            margin: EdgeInsets.all(3),
            width: 100,
            color: iqama != null && withDivider ? Colors.white : null,
          ),
          if (iqama != null)
            Text(
              iqama!,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                shadows: kHomeTextShadow,
              ),
            ),
        ],
      ),
    );
  }
}
