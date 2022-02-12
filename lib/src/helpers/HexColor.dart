
import 'dart:ui';

class HexColor extends Color {
  static int _getColorFromHex(String? hexColor) {

    if(hexColor != null){
      hexColor = hexColor.toUpperCase().replaceAll("#", "");
      if (hexColor.length == 6) {
        hexColor = "FF" + hexColor;
      }
      return int.parse(hexColor, radix: 16);
    }else {
      return int.parse("FFFFFF", radix: 16);
    }

  }

  HexColor(final String? hexColor) : super(_getColorFromHex(hexColor));
}


