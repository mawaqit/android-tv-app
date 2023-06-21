import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
          SvgPicture.asset(
            R.ASSETS_SVG_MAWAQIT_LOGO_TEXT_LIGHT_SVG,
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
                style: TextStyle(color: Colors.white, fontSize: 1.vwr),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
