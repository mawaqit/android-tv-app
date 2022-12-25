import 'package:flutter/material.dart';

class Config {
  /* Images Dir */
  static const String imageDir = "assets/img";

  /* Default Logo Application*/
  static Image logo =
      Image.asset("$imageDir/logo.png", height: 150, width: 150);

  static List<Map<String, String>> language = [
    {"value": "sq", "name": "Albanian", "subtitle": "Albanian"},
    {"value": "ar", "name": "Arabic", "subtitle": "العربية"},
    {"value": "bn", "name": "Bengali", "subtitle": "Bengali"},
    {"value": "hr", "name": "Croatian", "subtitle": "Croatian"},
    {"value": "nl", "name": "Dutch", "subtitle": "Dutch"},
    {"value": "en", "name": "English", "subtitle": "English"},
    {"value": "fr", "name": "French", "subtitle": "Français"},
    {"value": "de", "name": "German", "subtitle": "Deutsche"},
    {"value": "it", "name": "Italian", "subtitle": "Italiano"},
    {"value": "ml", "name": "Malayalam", "subtitle": "Malayalam"},
    {"value": "pt", "name": "Portuguese", "subtitle": "Português"},
    {"value": "es", "name": "Spanish", "subtitle": "Español"},
    {"value": "ta", "name": "Tamil", "subtitle": "Tamil"},
    {"value": "tr", "name": "Turkish", "subtitle": "Turc"},
    {"value": "ur", "name": "Urdu", "subtitle": "Urdu"}
  ];
}
