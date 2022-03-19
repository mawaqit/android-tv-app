import 'dart:convert';

import 'package:lottie/lottie.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/MawaqitAboutWidget.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 4,
            child: Align(
              child: Lottie.asset(
                'assets/animations/lottie/welcome.json',
                fit: BoxFit.contain,
              ),
              alignment: Alignment.center,
            ),
          ),
          Expanded(
            flex: 6,
            child: OnBoardingMawaqitAboutWidget(),
          ),
        ],
      ),
    );
  }
}
