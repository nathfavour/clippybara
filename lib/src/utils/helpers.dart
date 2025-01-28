import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

class Helpers {
  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid || Platform.isIOS) {
      var status = await Permission.location.request();
      if (!status.isGranted) {
        return false;
      }

      status = await Permission.storage.request();
      if (!status.isGranted) {
        return false;
      }
    }
    // On desktop or web, permissions might be handled differently or not required
    return true;
  }

  static void showError(String message) {
    // Implementation to show error messages, e.g., using Get.snackbar
    // Ensure that this works across all platforms
  }
}
