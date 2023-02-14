import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
void initHive() async {
  await Hive.initFlutter();
  await Hive.openBox<bool>('bool');
}

class HiveManager extends ChangeNotifier {
  var boolBox = Hive.box<bool>("bool");

  bool isSecondaryScreen() {
    return boolBox.get("secondaryScreen", defaultValue: false)!;
  }
  void putIsSecondaryScreen (bool value){
    boolBox.put("secondaryScreen", value);
    notifyListeners();
  }
  bool isWebView() {
    return boolBox.get("webView", defaultValue: false)!;
  }
  void putIsWebView (bool value){
    boolBox.put("webView", value);
    notifyListeners();
  }
}
