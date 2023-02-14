import 'package:flutter/material.dart';
import 'package:mawaqit/src/elements/RaisedGradientButton.dart';
import 'package:mawaqit/src/helpers/HexColor.dart';
import 'package:mawaqit/src/widgets/InfoWidget.dart';

import '../../i18n/l10n.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    Key? key,
    required this.title,
    required this.description,
    required this.image,
    this.onTryAgain,
    this.tryAgainText,
  }) : super(key: key);

  final String title;
  final String description;
  final String image;
  final VoidCallback? onTryAgain;
  final String? tryAgainText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Spacer(),
            Container(
                width: 100.0,
                height: 100.0,
                child: Image.asset(
                  image,
                  color: Colors.white70,
                  fit: BoxFit.contain,
                )),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(color: Colors.white70, fontSize: 40.0, fontWeight: FontWeight.bold),
            ),
            Text(
              description,
              style: TextStyle(color: Colors.white70, fontSize: 15.0),
            ),
            SizedBox(height: 20),
            RaisedGradientButton(
              autoFocus: true,
              child: Text(
                tryAgainText ?? S.of(context).tryAgain,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              width: 250,
              gradient: LinearGradient(colors: <Color>[HexColor("#391e61"), HexColor("#490094")]),
              onPressed: onTryAgain,
            ),
            Spacer(),
            Opacity(child: VersionWidget(),opacity: .3),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
