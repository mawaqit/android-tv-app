import 'package:flutter/material.dart';
import 'package:flyweb/src/helpers/AppConfig.dart';
import 'package:flyweb/src/helpers/HexColor.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/pages/onBoarding/widgets/MousqeSelectorWidget.dart';

class MosqueSearchScreen extends StatelessWidget {
  const MosqueSearchScreen({
    Key key,
    this.settings,
  }) : super(key: key);

  final Settings settings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor(settings.secondColor),
        title: Text('Mosque'),
      ),
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FractionallySizedBox(
                widthFactor: .75,
                child: Material(
                  color: AppColors().mainColor(.3),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 40,
                    ),
                    child: OnBoardingMosqueSelector(
                      onDone: () => Navigator.pop(context),
                    ),
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
