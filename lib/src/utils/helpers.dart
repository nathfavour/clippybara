import 'package:permission_handler/permission_handler.dart';

class Helpers {
  static Future<bool> requestPermissions() async {
    var status = await Permission.bluetooth.request();
    if (!status.isGranted) {
      return false;
    }

    status = await Permission.location.request();
    if (!status.isGranted) {
      return false;
    }

    status = await Permission.storage.request();
    if (!status.isGranted) {
      return false;
    }

    return true;
  }

  static void showError(String message) {
    // Implementation to show error messages, e.g., using Get.snackbar
  }
}
