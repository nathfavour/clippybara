import 'package:wifi_iot/wifi_iot.dart';
import '../models/clipboard_data.dart';
import '../models/device_info.dart';
import 'network_coordinator.dart';
import 'dart:async';
import 'dart:io' show Platform;

class WifiService {
  final NetworkCoordinator _coordinator = NetworkCoordinator();
  StreamSubscription? _devicesSubscription;
  bool _isInitialized = false;

  Stream<Map<String, DeviceInfo>> get connectedDevices =>
      _coordinator.devicesStream;
  Stream<ClipboardItem> get clipboardData => _coordinator.clipboardDataStream;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _coordinator.initialize();
      _isInitialized = true;
    } catch (e) {
      print('Error initializing network coordinator: $e');
      // If initialization fails, we'll try again with a delay
      await Future.delayed(const Duration(seconds: 5));
      await initialize();
    }
  }

  Future<bool> connectToWifi(String ssid, String password) async {
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        await WiFiForIoTPlugin.disconnect();
        await WiFiForIoTPlugin.connect(
          ssid,
          password: password,
          security: NetworkSecurity.WPA,
        );
        return true;
      } catch (e) {
        print('Error connecting to WiFi: $e');
        return false;
      }
    }
    return false;
  }

  Future<void> startWifiSharing() async {
    await initialize();
  }

  Future<void> stopWifiSharing() async {
    _devicesSubscription?.cancel();
    _coordinator.dispose();
    _isInitialized = false;
  }

  Future<void> sendData(ClipboardItem data) async {
    if (!_isInitialized) {
      await initialize();
    }
    await _coordinator.broadcastClipboardData(data);
  }

  void dispose() {
    stopWifiSharing();
  }
}
