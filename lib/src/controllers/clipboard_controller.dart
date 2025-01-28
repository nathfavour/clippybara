import 'package:get/get.dart';
import '../services/connectivity_service.dart';
import '../services/wifi_service.dart';
import '../models/clipboard_data.dart';
import 'dart:io' show Platform;

class ClipboardController extends GetxController {
  final _clipboardContent = ''.obs;
  final _connectedDevices = <String>[].obs;
  final _isSharing = false.obs;
  final _useWifi = false.obs;

  final ConnectivityService _connectivityService = ConnectivityService();
  final WifiService _wifiService = WifiService();

  String get clipboardContent => _clipboardContent.value;
  List<String> get connectedDevices => _connectedDevices;
  bool get isSharing => _isSharing.value;
  bool get useWifi => _useWifi.value;

  Future<void> startSharing() async {
    _isSharing.value = true;
    if (_useWifi.value) {
      await _wifiService.startWifiSharing();
    }
    if (Platform.isAndroid || Platform.isIOS) {
      await _connectivityService.startDiscovery();
    }
  }

  Future<void> stopSharing() async {
    _isSharing.value = false;
    if (_useWifi.value) {
      await _wifiService.stopWifiSharing();
    }
    if (Platform.isAndroid || Platform.isIOS) {
      await _connectivityService.stopDiscovery();
    }
  }

  Future<void> sendClipboardData(ClipboardData data) async {
    if (_useWifi.value) {
      await _wifiService.sendData(data);
    }
    if (Platform.isAndroid || Platform.isIOS) {
      await _connectivityService.sendData(data);
    }
  }

  void updateClipboardContent(String content) {
    _clipboardContent.value = content;
  }

  void setUseWifi(bool value) {
    _useWifi.value = value;
  }
}
