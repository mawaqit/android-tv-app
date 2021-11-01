import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loader extends StatefulWidget {
  String type;
  Color color;

  Loader({Key key, this.type = "", this.color = Colors.white})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _Loader();
  }
}

class _Loader extends State<Loader> {
  @override
  Widget build(BuildContext context) {
    String type = widget.type;
    Color color = widget.color;
    double size = 60.0;

    Widget loader;
    switch (type) {
      case "RotatingPlain":
        loader = SpinKitRotatingPlain(
          color: color,
          size: size,
        );
        break;

      case "FadingFour":
        loader = SpinKitFadingFour(
          color: color,
          size: size,
        );
        break;

      case "FadingCube":
        loader = SpinKitFadingCube(
          color: color,
          size: size,
        );
        break;
      case "Pulse":
        loader = SpinKitPulse(
          color: color,
          size: size,
        );
        break;
      case "ChasingDots":
        loader = SpinKitChasingDots(
          color: color,
          size: size,
        );
        break;
      case "ThreeBounce":
        loader = SpinKitThreeBounce(
          color: color,
          size: size,
        );
        break;
      case "Circle":
        loader = SpinKitCircle(
          color: color,
          size: size,
        );
        break;
      case "CubeGrid":
        loader = SpinKitCubeGrid(
          color: color,
          size: size,
        );
        break;
      case "FadingCircle":
        loader = SpinKitFadingCircle(
          color: color,
          size: size,
        );
        break;
      case "FoldingCube":
        loader = SpinKitFoldingCube(
          color: color,
          size: size,
        );
        break;
      case "PumpingHeart":
        loader = SpinKitPumpingHeart(
          color: color,
          size: size,
        );
        break;
      case "DualRing":
        loader = SpinKitDualRing(
          color: color,
          size: size,
        );
        break;
      case "HourGlass":
        loader = SpinKitHourGlass(
          color: color,
          size: size,
        );
        break;
      case "FadingGrid":
        loader = SpinKitFadingGrid(
          color: color,
          size: size,
        );
        break;
      case "Ring":
        loader = SpinKitRing(
          color: color,
          size: size,
        );
        break;
      case "Ripple":
        loader = SpinKitRipple(
          color: color,
          size: size,
        );
        break;
      case "SpinningCircle":
        loader = SpinKitSpinningCircle(
          color: color,
          size: size,
        );
        break;
      case "SquareCircle":
        loader = SpinKitSquareCircle(
          color: color,
          size: size,
        );
        break;
      case "WanderingCubes":
        loader = SpinKitWanderingCubes(
          color: color,
          size: size,
        );
        break;
      case "Wave":
        loader = SpinKitWave(
          color: color,
          size: size,
        );
        break;
      case "DoubleBounce":
        loader = SpinKitDoubleBounce(
          color: color,
          size: size,
        );
        break;
      case "empty":
        loader = Container();
        break;
      default:
        loader = Container();
        break;
    }

    return loader;
  }
}
