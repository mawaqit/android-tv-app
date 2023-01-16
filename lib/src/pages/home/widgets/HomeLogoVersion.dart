import 'package:flutter/material.dart';
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
           height: 40,
         ),
        Positioned(
          top: 0,
          bottom: -2,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment(.5, 1.4),
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(5),
                  bottom: Radius.circular(10),
                ),
              ),
              child: VersionWidget(
                style: TextStyle(color: Colors.grey, fontSize: 8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
