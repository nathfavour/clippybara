import 'package:get/get.dart';
import '../services/connectivity_service.dart';
import '../services/bluetooth_service.dart';
import '../services/wifi_service.dart';
import '../models/clipboard_data.dart';

class ClipboardController extends GetxController {
  final _clipboardContent = ''.obs;
  final _connectedDevices = <String>[].obs;
  final _isSharing = false.obs;

  final ConnectivityService _connectivityService = ConnectivityService();
  final BluetoothService _bluetoothService = BluetoothService();
  final WifiService _wifiService = WifiService();

  String get clipboardContent => _clipboardContent.value;
  List<String> get connectedDevices => _connectedDevices;
  bool get isSharing => _isSharing.value;

  Future<void> startSharing() async {
    _isSharing.value = true;
    await _connectivityService.startDiscovery();
  }

  Future<void> stopSharing() async {
    _isSharing.value = false;
    await _connectivityService.stopDiscovery();
  }

  Future<void> sendClipboardData(ClipboardData data) async {
    // Implementation for sending clipboard data
  }

  void updateClipboardContent(String content) {
    _clipboardContent.value = content;
  }
}
