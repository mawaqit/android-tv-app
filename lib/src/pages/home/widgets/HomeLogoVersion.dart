import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/widgets/InfoWidget.dart';

class HomeLogoVersion extends StatelessWidget {
  const HomeLogoVersion({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Image.asset(
          'assets/img/logo/logo-mawaqit-2022-horizontal.png',
          height: 3.8.vw,
        ),
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment(.5, 1.3),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: .5.vw,
                vertical: .4.vh,
              ),
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
        ),
      ],
    );
  }
}
