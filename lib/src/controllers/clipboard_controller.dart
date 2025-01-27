import 'package:get/get.dart';
import '../services/connectivity_service.dart';
import '../services/bluetooth_service.dart';
import '../services/wifi_service.dart';
import '../models/clipboard_data.dart';

class ClipboardController extends GetxController {
  final _clipboardContent = ''.obs;
  final _connectedDevices = <String>[].obs;
  final _isSharing = false.obs;
  final _useWifi = false.obs;
  final _useBluetooth = false.obs;

  final ConnectivityService _connectivityService = ConnectivityService();
  final BluetoothService _bluetoothService = BluetoothService();
  final WifiService _wifiService = WifiService();

  String get clipboardContent => _clipboardContent.value;
  List<String> get connectedDevices => _connectedDevices;
  bool get isSharing => _isSharing.value;
  bool get useWifi => _useWifi.value;
  bool get useBluetooth => _useBluetooth.value;

  Future<void> startSharing() async {
    _isSharing.value = true;
    if (_useWifi.value) {
      await _connectivityService.startWifiSharing();
    }
    if (_useBluetooth.value) {
      await _bluetoothService.startBluetoothSharing();
    }
  }

  Future<void> stopSharing() async {
    _isSharing.value = false;
    if (_useWifi.value) {
      await _connectivityService.stopWifiSharing();
    }
    if (_useBluetooth.value) {
      await _bluetoothService.stopBluetoothSharing();
    }
  }

  Future<void> sendClipboardData(ClipboardData data) async {
    if (_useWifi.value) {
      await _connectivityService.sendData(data);
    }
    if (_useBluetooth.value) {
      await _bluetoothService.sendData(data);
    }
  }

  void updateClipboardContent(String content) {
    _clipboardContent.value = content;
  }

  void setUseWifi(bool value) {
    _useWifi.value = value;
  }

  void setUseBluetooth(bool value) {
    _useBluetooth.value = value;
  }
}
