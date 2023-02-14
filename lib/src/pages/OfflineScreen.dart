import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/elements/RaisedGradientButton.dart';
import 'package:mawaqit/src/helpers/HexColor.dart';


class OfflineScreen extends StatefulWidget {
  final VoidCallback onPressedTryAgain;
  const OfflineScreen({Key? key, required this.onPressedTryAgain}) : super(key: key);

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
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
                    R.ASSETS_IMG_WIFI_PNG,
                    color: Colors.white70,
                    fit: BoxFit.contain,
                  )),
              Text(
                S.of(context).whoops,
                style: TextStyle(color: Colors.white70, fontSize: 40.0, fontWeight: FontWeight.bold),
              ),
              Text(
                S.of(context).noInternet,
                style: TextStyle(color: Colors.white70, fontSize: 15.0),
              ),
              SizedBox(height: 20),
              RaisedGradientButton(

                child: Text(
                  S.of(context).tryAgain,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                width: 250,
                gradient: LinearGradient(
                  colors: <Color>[
                    HexColor("#391e61"),
                    HexColor("#490094"),
                  ],
                ),
                onPressed: widget.onPressedTryAgain,
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    return _showDialog();
  }

  _showDialog() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text(S.of(context).closeApp),
        content: new Text(S.of(context).sureCloseApp),
        actions: <Widget>[
          new TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text(S.of(context).cancel),
          ),
          SizedBox(height: 16),
          new TextButton(
            onPressed: () => exit(0),
            child: new Text(S.of(context).ok),
          ),
        ],
      ),
    );
  }
}
