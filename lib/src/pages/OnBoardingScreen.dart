import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flyweb/src/helpers/HexColor.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/pages/HomeScreen.dart';
import 'package:flyweb/src/widgets/slide_dots.dart';
import 'package:flyweb/src/widgets/slide_items/slide_item.dart';

class OnBoardingScreen extends StatefulWidget {
  final String url;
  final Settings settings;

  const OnBoardingScreen(this.url, this.settings);

  @override
  State<StatefulWidget> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_currentPage < widget.settings.sliders.length) {
        _pageController.nextPage(
          duration: Duration(milliseconds: 700),
          curve: Curves.ease,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: topSliderLayout(),
    );
  }

  Widget topSliderLayout() => Container(
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: <Widget>[
            PageView.builder(
              scrollDirection: Axis.horizontal,
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: widget.settings.sliders.length,
              itemBuilder: (ctx, i) => SlideItem(i, widget.settings.sliders),
            ),
            Padding(
                padding: EdgeInsets.all(10.0),
                child: Stack(
                  alignment: AlignmentDirectional.topStart,
                  children: <Widget>[
                    _currentPage == widget.settings.sliders.length - 1
                        ? Align(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton(
                              child: Text(
                                  _currentPage <
                                          widget.settings.sliders.length - 1
                                      ? "NEXT"
                                      : "GET START",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.0,
                                  )),
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          HexColor(widget.settings.firstColor)),
                                  shadowColor: MaterialStateProperty.all<Color>(
                                      Colors.white)),
                              onPressed: () {
                                if (_currentPage <
                                    widget.settings.sliders.length - 1)
                                  _pageController.nextPage(
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.ease,
                                  );
                                else {
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              HomeScreen(widget.url,
                                                  widget.settings)));
                                }
                              },
                            )
                            )
                        : Container(),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 15.0, bottom: 15.0),
                        child: RichText(
                          text: TextSpan(
                            style:
                                TextStyle(color: Colors.grey, fontSize: 20.0),
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'Skip',
                                  style: TextStyle(
                                    color: HexColor(widget.settings.firstColor),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.0,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  HomeScreen(widget.url,
                                                      widget.settings)));
                                    }),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      alignment: AlignmentDirectional.bottomCenter,
                      margin: EdgeInsets.only(bottom: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          for (int i = 0;
                              i < widget.settings.sliders.length;
                              i++)
                            if (i == _currentPage)
                              SlideDots(true, widget.settings.firstColor)
                            else
                              SlideDots(false, widget.settings.firstColor)
                        ],
                      ),
                    ),
                  ],
                ))
          ],
        ),
      );
}
