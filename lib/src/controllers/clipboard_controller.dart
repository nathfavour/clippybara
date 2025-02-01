import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../services/connectivity_service.dart';
import '../services/wifi_service.dart';
import '../services/network_discovery_service.dart';
import '../models/clipboard_data.dart' as app;
import '../utils/helpers.dart';
import 'dart:async';
import 'dart:io' show Platform;

class ClipboardController extends GetxController {
  final _clipboardContent = ''.obs;
  final _connectedDevices = <DeviceInfo>[].obs;
  final _isSharing = true.obs; // Default to true for automatic sync
  final _useWifi = true.obs;
  final _syncEnabled = true.obs;
  final _autoConnect = true.obs;
  final _notificationsEnabled = true.obs;
  final _clipboardHistory = <app.ClipboardItem>[].obs;
  final _lastSyncTime = Rx<DateTime?>(null);

  final NetworkDiscoveryService _discoveryService = NetworkDiscoveryService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final WifiService _wifiService = WifiService();
  Timer? _clipboardCheckTimer;

  String get clipboardContent => _clipboardContent.value;
  List<DeviceInfo> get connectedDevices => _connectedDevices;
  bool get isSharing => _isSharing.value;
  bool get useWifi => _useWifi.value;
  bool get syncEnabled => _syncEnabled.value;
  bool get autoConnect => _autoConnect.value;
  bool get notificationsEnabled => _notificationsEnabled.value;
  List<app.ClipboardItem> get clipboardHistory => _clipboardHistory;
  DateTime? get lastSyncTime => _lastSyncTime.value;

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    _startClipboardMonitoring();
  }

  Future<void> _initializeServices() async {
    await _discoveryService.initialize();
    _discoveryService.onDeviceDiscovered.listen(_handleDeviceDiscovered);

    if (_autoConnect.value) {
      await startSharing();
    }

    // Start monitoring clipboard
    await _checkClipboard();
  }

  void _startClipboardMonitoring() {
    _clipboardCheckTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _checkClipboard(),
    );
  }

  Future<void> _checkClipboard() async {
    if (!_syncEnabled.value) return;

    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    final newContent = clipboardData?.text ?? '';

    if (newContent != _clipboardContent.value) {
      _clipboardContent.value = newContent;
      _addToHistory(newContent);
      if (_isSharing.value) {
        await _syncClipboard();
      }
    }
  }

  void _addToHistory(String content) async {
    final newData = app.ClipboardItem(
      content: content,
      timestamp: DateTime.now(),
      deviceId: await Helpers.getDeviceId(),
    );
    _clipboardHistory.insert(0, newData);
    if (_clipboardHistory.length > 50) {
      // Keep last 50 items
      _clipboardHistory.removeLast();
    }
  }

  Future<void> _syncClipboard() async {
    final deviceId = await Helpers.getDeviceId();
    final data = app.ClipboardItem(
      content: _clipboardContent.value,
      timestamp: DateTime.now(),
      deviceId: deviceId,
    );

    if (_useWifi.value) {
      await _wifiService.sendData(data);
    }
    if (Platform.isAndroid || Platform.isIOS) {
      await _connectivityService.sendData(data);
    }
    _lastSyncTime.value = DateTime.now();
  }

  void _handleDeviceDiscovered(String deviceId) {
    final deviceInfo = DeviceInfo(
      id: deviceId,
      name: 'Device ${_connectedDevices.length + 1}',
      lastSeen: DateTime.now(),
    );
    if (!_connectedDevices.any((device) => device.id == deviceId)) {
      _connectedDevices.add(deviceInfo);
    }
  }

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

  void setAutoConnect(bool value) {
    _autoConnect.value = value;
  }

  void setSyncEnabled(bool value) {
    _syncEnabled.value = value;
    if (!value) {
      stopSharing();
    } else if (_autoConnect.value) {
      startSharing();
    }
  }

  void setUseWifi(bool value) async {
    _useWifi.value = value;
    if (_isSharing.value) {
      await stopSharing();
      await startSharing();
    }
  }

  void setNotificationsEnabled(bool value) {
    _notificationsEnabled.value = value;
  }

  void clearHistory() {
    _clipboardHistory.clear();
  }

  // Add missing public methods used by HomePage
  void addClipboardItem(String text) async {
    _clipboardContent.value = text;
    _addToHistory(text);
    if (_syncEnabled.value) {
      await _syncClipboard();
    }
  }

  void shareWithConnectedDevices(String text) async {
    _clipboardContent.value = text;
    if (_syncEnabled.value) {
      await _syncClipboard();
    }
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  void removeFromHistory(int index) {
    if (index >= 0 && index < _clipboardHistory.length) {
      _clipboardHistory.removeAt(index);
    }
  }

  @override
  void onClose() {
    _clipboardCheckTimer?.cancel();
    _discoveryService.dispose();
    super.onClose();
  }
}

class DeviceInfo {
  final String id;
  final String name;
  final DateTime lastSeen;

  DeviceInfo({
    required this.id,
    required this.name,
    required this.lastSeen,
  });
}
