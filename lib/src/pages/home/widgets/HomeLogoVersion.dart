import 'package:flutter/material.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/widgets/InfoWidget.dart';

class HomeLogoVersion extends StatelessWidget {
  const HomeLogoVersion({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            R.ASSETS_IMG_LOGO_LOGO_MAWAQIT_2022_HORIZONTAL_PNG,
            height: 3.8.vw,
          ),
          Align(
            heightFactor: .5,
            alignment: Alignment(.5, 0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: .5.vw, vertical: .4.vh),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(5),
                  bottom: Radius.circular(10),
                ),
              ),
              child: VersionWidget(
                style: TextStyle(color: Colors.white, fontSize: 1.vw),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
