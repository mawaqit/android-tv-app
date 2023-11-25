import 'package:google_fonts/google_fonts.dart';

class FontManager {
 static String? getFontFamily(String local) {
    switch (local) {
      case 'ar':
        return GoogleFonts.amiri().fontFamily;
      case 'tr':
        return GoogleFonts.amiri().fontFamily;
      default:
        return null;
    }
  }
}
