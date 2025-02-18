import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../services/connectivity_service.dart';
import '../services/wifi_service.dart';
import '../models/clipboard_data.dart' as app;
import '../utils/helpers.dart';
import 'dart:async';
import 'dart:io' show Platform;

class ClipboardController extends GetxController {
  final _clipboardContent = ''.obs;
  final _isSharing = true.obs;
  final _useWifi = true.obs;
  final _syncEnabled = true.obs;
  final _clipboardHistory = <app.ClipboardItem>[].obs;

  final ConnectivityService _connectivityService = ConnectivityService();
  final WifiService _wifiService = WifiService();
  Timer? _clipboardCheckTimer;

  String get clipboardContent => _clipboardContent.value;
  bool get isSharing => _isSharing.value;
  bool get useWifi => _useWifi.value;
  bool get syncEnabled => _syncEnabled.value;
  List<app.ClipboardItem> get clipboardHistory => _clipboardHistory;

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    _startClipboardMonitoring();
  }

  Future<void> _initializeServices() async {
    if (_syncEnabled.value) {
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

  void setSyncEnabled(bool value) {
    _syncEnabled.value = value;
    if (!value) {
      stopSharing();
    } else {
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

  @override
  void onClose() {
    _clipboardCheckTimer?.cancel();
    super.onClose();
  }
}
