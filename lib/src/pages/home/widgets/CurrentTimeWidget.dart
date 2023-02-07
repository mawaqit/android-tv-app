import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';

class CurrentTimeWidget extends StatelessWidget {
  const CurrentTimeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.watch<MosqueManager>();
    final now = mosqueManager.mosqueDate();

    final mosqueConfig = mosqueManager.mosqueConfig;
    bool is12hourFormat = mosqueConfig?.timeDisplayFormat == "12";

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormat(
              "${is12hourFormat ? "hh:mm" : "HH:mm"}",
              'en',
            ).format(now),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 8.vw,
              shadows: kHomeTextShadow,
              color: Colors.white,
              height: 1,
              // letterSpacing: 1,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ':${DateFormat('ss', 'en').format(now)}',
                style: TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: is12hourFormat ? 4.vw : 6.vw,
                  shadows: kHomeTextShadow,
                  height: is12hourFormat ? 1 : null,
                  // letterSpacing: 1.vw,
                ),
              ),
              if (is12hourFormat)
                Padding(
                  padding: EdgeInsets.only(bottom: .6.vh, left: .9.vw),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 8.vw),
                    child: FittedBox(
                      child: Text(
                        '${DateFormat('a').format(now)}',
                        style: TextStyle(
                          color: Colors.white54,
                          fontWeight: FontWeight.bold,
                          fontSize: 3.2.vw,
                          shadows: kHomeTextShadow,
                          height: .9,

                          // letterSpacing: 1.vw,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],

        // date time
      ),
    );
  }
}
