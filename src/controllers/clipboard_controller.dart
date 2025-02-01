import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../models/clipboard_data.dart';
// ...existing imports and code...

class ClipboardController extends GetxController {
  // ...existing properties...
  var clipboardContent = ''.obs;
  var clipboardHistory = <ClipboardItem>[].obs;
  var syncEnabled = false.obs;
  var autoConnect = false.obs;
  var useWifi = false.obs;
  var notificationsEnabled = false.obs;
  var isSharing = false.obs;
  var connectedDevices =
      <dynamic>[].obs; // Replace dynamic with your Device type

  // New methods implementation:
  void addClipboardItem(String text) {
    final newItem = ClipboardItem(content: text, timestamp: DateTime.now());
    clipboardContent.value = text;
    clipboardHistory.insert(0, newItem);
  }

  void shareWithConnectedDevices(String text) {
    // Implement sharing logic, for example via WifiService or another service.
    print("Sharing: $text");
    // ...existing sharing implementation...
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    print("Copied to clipboard: $text");
  }

  void removeFromHistory(int index) {
    if (index >= 0 && index < clipboardHistory.length) {
      clipboardHistory.removeAt(index);
    }
  }

  // ...existing methods...
}
