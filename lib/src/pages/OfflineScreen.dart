import 'package:flutter/material.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/src/elements/RaisedGradientButton.dart';
import 'package:mawaqit/src/helpers/HexColor.dart';
import 'package:mawaqit/src/services/settings_manager.dart';
import 'package:mawaqit/src/themes/UIImages.dart';
import 'package:provider/provider.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = context.read<SettingsManager>().settings;

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Spacer(),
            Container(
                width: 100.0,
                height: 100.0,
                child: Image.asset(
                  UIImages.imageDir + "/wifi.png",
                  color: Colors.black26,
                  fit: BoxFit.contain,
                )),
            Text(
              S.of(context).whoops,
              style: TextStyle(color: Colors.black45, fontSize: 40.0, fontWeight: FontWeight.bold),
            ),
            Text(
              S.of(context).noInternet,
              style: TextStyle(color: Colors.black87, fontSize: 15.0),
            ),
            SizedBox(height: 20),
            RaisedGradientButton(
              child: Text(
                S.of(context).tryAgain,
                style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              width: 250,
              gradient: LinearGradient(
                colors: <Color>[HexColor(settings.secondColor), HexColor(settings.firstColor)],
              ),
              onPressed: () {},
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
