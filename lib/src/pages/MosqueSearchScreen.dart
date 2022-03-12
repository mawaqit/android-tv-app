import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/MousqeSelectorWidget.dart';

class MosqueSearchScreen extends StatelessWidget {
  const MosqueSearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 4,
            child: Center(
              child: Lottie.asset(
                'assets/animations/lottie/search.json',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: OnBoardingMosqueSelector(onDone: AppRouter.pop),
          ),
        ],
      ),
    );
  }
}
