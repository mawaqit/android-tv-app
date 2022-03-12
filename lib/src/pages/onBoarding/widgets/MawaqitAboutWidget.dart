import 'package:flutter/material.dart';
import 'package:mawaqit/generated/l10n.dart';

class OnBoardingMawaqitAboutWidget extends StatelessWidget {
  const OnBoardingMawaqitAboutWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Align(
      alignment: Alignment(0, -.3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            S.of(context).mawaqitWelcome,
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 10),
          Text(
            S.of(context).mawaqitDesc,
            style: TextStyle(
              fontSize: 19,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
        ],
      ),
    );
  }
}
