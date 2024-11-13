import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class ApkInstaller {
  static const platform = MethodChannel('nativeMethodsChannel');

  Future<void> downloadAndInstallApk(String downloadUrl) async {
    try {
      // Get temporary directory to store APK
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/app.apk';

      // Download APK file
      final response = await http.get(Uri.parse(downloadUrl));
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // Call native method to install APK
      try {
        final result = await platform.invokeMethod('installApk', {
          'filePath': filePath,
        });
        print('Installation result: $result');
      } on PlatformException catch (e) {
        print('Failed to install APK: ${e.message}');
      }

      // Clean up - delete temporary file
      await file.delete();
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }
}
