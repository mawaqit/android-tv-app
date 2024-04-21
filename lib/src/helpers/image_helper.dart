import 'dart:developer';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ImageHelper {
  /// [loadImageFromUrl] loads an image in Uint8List format from the provided url
  static Future<Uint8List?> loadImageFromUrl(String? url) async {
    if (url == null || url.isEmpty) return null;
    log('announcement: ImageHelper: loadImageFromUrl $url');
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw ('Error loading image: ${response.statusCode}');
      }
    } catch (e) {
      throw ('Error loading image: $e');
    }
  }
}
