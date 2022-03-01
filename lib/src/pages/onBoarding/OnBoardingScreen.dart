import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flyweb/src/helpers/AppConfig.dart';
import 'package:flyweb/src/helpers/AppRouter.dart';
import 'package:flyweb/src/helpers/SharedPref.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/pages/HomeScreen.dart';
import 'package:flyweb/src/pages/onBoarding/widgets/LanuageSelectorWidget.dart';
import 'package:flyweb/src/pages/onBoarding/widgets/MousqeSelectorWidget.dart';
import 'package:flyweb/src/pages/onBoarding/widgets/TextScreenWidget.dart';
import 'package:google_fonts/google_fonts.dart';

// class OnBoardingScreen extends StatefulWidget {
//   final String url;
//   final Settings settings;
//
//   const OnBoardingScreen(this.url, this.settings);
//
//   @override
//   State<StatefulWidget> createState() => _OnBoardingScreenState();
// }
//
// class _OnBoardingScreenState extends State<OnBoardingScreen> {
//   int _currentPage = 0;
//   final PageController _pageController = PageController(initialPage: 0);
//
//   @override
//   void initState() {
//     super.initState();
//     Timer.periodic(Duration(seconds: 5), (Timer timer) {
//       if (_currentPage < widget.settings.sliders.length) {
//         _pageController.nextPage(
//           duration: Duration(milliseconds: 700),
//           curve: Curves.ease,
//         );
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   _onPageChanged(int index) {
//     setState(() => _currentPage = index);
//   }
//
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: topSliderLayout(),
//     );
//   }
//
//   Widget topSliderLayout() => Container(
//         child: Stack(
//           alignment: AlignmentDirectional.bottomCenter,
//           children: <Widget>[
//             PageView.builder(
//               scrollDirection: Axis.horizontal,
//               controller: _pageController,
//               onPageChanged: _onPageChanged,
//               itemCount: widget.settings.sliders.length,
//               itemBuilder: (ctx, i) => SlideItem(i, widget.settings.sliders),
//             ),
//             Padding(
//                 padding: EdgeInsets.all(10.0),
//                 child: Stack(
//                   alignment: AlignmentDirectional.topStart,
//                   children: <Widget>[
//                     _currentPage == widget.settings.sliders.length - 1
//                         ? Align(
//                             alignment: Alignment.bottomRight,
//                             child: ElevatedButton(
//                               child: Text(
//                                 _currentPage <
//                                         widget.settings.sliders.length - 1
//                                     ? "NEXT"
//                                     : "GET START",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 14.0,
//                                 ),
//                               ),
//                               style: ButtonStyle(
//                                 backgroundColor:
//                                     MaterialStateProperty.all<Color>(
//                                         HexColor(widget.settings.firstColor)),
//                                 shadowColor: MaterialStateProperty.all<Color>(
//                                   Colors.white,
//                                 ),
//                               ),
//                               onPressed: () {
//                                 if (_currentPage <
//                                     widget.settings.sliders.length - 1)
//                                   _pageController.nextPage(
//                                     duration: Duration(milliseconds: 500),
//                                     curve: Curves.ease,
//                                   );
//                                 else {
//                                   Navigator.of(context).pushReplacement(
//                                     MaterialPageRoute(
//                                       builder: (BuildContext context) =>
//                                           HomeScreen(
//                                         widget.url,
//                                         widget.settings,
//                                       ),
//                                     ),
//                                   );
//                                 }
//                               },
//                             ))
//                         : Container(),
//                     Align(
//                       alignment: Alignment.bottomLeft,
//                       child: Padding(
//                         padding: EdgeInsets.only(left: 15.0, bottom: 15.0),
//                         child: RichText(
//                           text: TextSpan(
//                             style:
//                                 TextStyle(color: Colors.grey, fontSize: 20.0),
//                             children: <TextSpan>[
//                               TextSpan(
//                                 text: 'Skip',
//                                 style: TextStyle(
//                                   color: HexColor(widget.settings.firstColor),
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 14.0,
//                                 ),
//                                 recognizer: TapGestureRecognizer()
//                                   ..onTap = () {
//                                     Navigator.of(context).pushReplacement(
//                                       MaterialPageRoute(
//                                         builder: (BuildContext context) =>
//                                             HomeScreen(
//                                           widget.url,
//                                           widget.settings,
//                                         ),
//                                       ),
//                                     );
//                                   },
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       alignment: AlignmentDirectional.bottomCenter,
//                       margin: EdgeInsets.only(bottom: 20.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: <Widget>[
//                           for (int i = 0;
//                               i < widget.settings.sliders.length;
//                               i++)
//                             if (i == _currentPage)
//                               SlideDots(true, widget.settings.firstColor)
//                             else
//                               SlideDots(false, widget.settings.firstColor)
//                         ],
//                       ),
//                     ),
//                   ],
//                 ))
//           ],
//         ),
//       );
// }

enum _ScreenState { Text, Mosque, Language }

class OnBoardingScreen extends StatefulWidget {
  // final String url;
  final Settings settings;

  const OnBoardingScreen(this.settings);

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  var state = _ScreenState.Text;
  final sharedPref = SharedPref();

  _onDone() async {
    sharedPref.save('boarding', 'true');

    AppRouter.pushReplacement(HomeScreen(widget.settings));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            image: widget.settings.splash?.img_splash_base64 == null
                ? AssetImage('assets/img/background.png')
                : MemoryImage(
                    base64Decode(
                      widget.settings.splash!.img_splash_base64!,
                    ),
                  ) as ImageProvider,
          ),
        ),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              Center(
                child: Image.asset(
                  'assets/img/mawaqit_logo_light_with_text_horizontal_Background.png',
                  width: 200,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                "WELCOME TO",
                style: GoogleFonts.montserrat(
                  color: AppColors().mainColor(.7),
                  fontWeight: FontWeight.w300,
                  height: 1.2,
                  fontSize: 18,
                  fontStyle: FontStyle.normal,
                ),
                textAlign: TextAlign.center,
              ),
              Center(
                child: Text(
                  "MAWAQIT",
                  style: GoogleFonts.montserrat(
                    color: AppColors().mainColor(),
                    letterSpacing: 4,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    fontSize: 30,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FractionallySizedBox(
                widthFactor: .75,
                child: Material(
                  // color: Color(0x8042039D),
                  color: AppColors().mainColor(.3),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 40,
                    ),
                    child: Builder(builder: (context) {
                      switch (state) {
                        case _ScreenState.Text:
                          return OnBoardingTextWidget(
                            onDone: () =>
                                setState(() => state = _ScreenState.Language),
                          );
                        case _ScreenState.Language:
                          return WillPopScope(
                            onWillPop: () async {
                              setState(() => state = _ScreenState.Text);
                              return false;
                            },
                            child: OnBoardingLanguageSelector(
                              onDone: () =>
                                  setState(() => state = _ScreenState.Mosque),
                            ),
                          );
                        case _ScreenState.Mosque:
                          return WillPopScope(
                            onWillPop: () async {
                              setState(() => state = _ScreenState.Language);
                              return false;
                            },
                            child: OnBoardingMosqueSelector(onDone: _onDone),
                          );

                        default:
                          throw Exception('Unknown state ');
                      }
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
