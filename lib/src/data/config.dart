import 'package:flutter/material.dart';

class Config {
  /* Images Dir */
  static const String imageDir = "assets/img";

  /* Default Logo Application*/
  static Image logo =
      Image.asset("$imageDir/logo.png", height: 150, width: 150);

  static List language = [
    {"value": "en", "name": "English", "subtitle": "English"},
    {"value": "ar", "name": "Arabic", "subtitle": "العربية"},
    {"value": "es", "name": "Spanish", "subtitle": "Español"},
    {"value": "fr", "name": "French", "subtitle": "Français"},
    {"value": "pt", "name": "Portuguese", "subtitle": "Português"},
    {"value": "hi", "name": "Hindi", "subtitle": "हिन्दी"},
    {"value": "de", "name": "German", "subtitle": "Deutsche"},
    {"value": "it", "name": "Italian", "subtitle": "Italiano"},
    {"value": "tr", "name": "Turkish", "subtitle": "Turc"},
    {"value": "ru", "name": "Russian", "subtitle": "русский язык"}
  ];
}
