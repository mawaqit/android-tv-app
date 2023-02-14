import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/LanuageSelectorWidget.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 4,
            child: Align(
              child: Lottie.asset(
                R.ASSETS_ANIMATIONS_LOTTIE_LANGUAGE_JSON,
                fit: BoxFit.contain,
              ),
              alignment: Alignment.center,
            ),
          ),
          Expanded(
            flex: 6,
            child: OnBoardingLanguageSelector(onSelect: AppRouter.pop),
          ),
        ],
      ),
    );
  }
// AppBar _renderAppBar(context) {
//   final settingsManager = Provider.of<SettingsManager>(context);
//   final settings = settingsManager.settings;
//
//   return AppBar(
//       title: Text(
//         S.of(context).languages,
//         style: TextStyle(color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.bold),
//       ),
//       flexibleSpace: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.centerLeft,
//             end: Alignment.centerRight,
//             colors: <Color>[
//               Theme.of(context).brightness == Brightness.light
//                   ? HexColor(settings.firstColor)
//                   : Theme.of(context).primaryColor,
//               Theme.of(context).brightness == Brightness.light
//                   ? HexColor(settings.secondColor)
//                   : Theme.of(context).primaryColor,
//             ],
//           ),
//         ),
//       ));
// }
}
