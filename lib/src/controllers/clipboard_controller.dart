import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../services/connectivity_service.dart';
import '../services/wifi_service.dart';
import '../models/clipboard_data.dart' as app;
import '../utils/helpers.dart';
import 'dart:async';
import 'dart:io' show Platform, Socket;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/device_info.dart';
import '../services/network_discovery_service.dart';

class ClipboardController extends GetxController {
  final _clipboardContent = ''.obs;
  final _isSharing = true.obs;
  final _useWifi = true.obs;
  final _syncEnabled = true.obs;
  final _clipboardHistory = <app.ClipboardItem>[].obs;
  final RxList<DeviceInfo> _connectedDevices = <DeviceInfo>[].obs;
  final _autoConnect = true.obs;
  final _notificationsEnabled = true.obs;

  final ConnectivityService _connectivityService = ConnectivityService();
  final WifiService _wifiService = WifiService();
  final NetworkDiscoveryService _networkDiscoveryService =
      NetworkDiscoveryService();
  Timer? _clipboardCheckTimer;

  String get clipboardContent => _clipboardContent.value;
  bool get isSharing => _isSharing.value;
  bool get useWifi => _useWifi.value;
  bool get syncEnabled => _syncEnabled.value;
  List<app.ClipboardItem> get clipboardHistory => _clipboardHistory;
  List<DeviceInfo> get connectedDevices => _connectedDevices;
  bool get autoConnect => _autoConnect.value;
  bool get notificationsEnabled => _notificationsEnabled.value;

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    _startClipboardMonitoring();
    _startDeviceDiscovery();
  }

  Future<void> _initializeServices() async {
    if (_syncEnabled.value) {
      await startSharing();
    }

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

  void setAutoConnect(bool value) {
    _autoConnect.value = value;
  }

  void setNotificationsEnabled(bool value) {
    _notificationsEnabled.value = value;
  }

  void clearHistory() {
    _clipboardHistory.clear();
  }

  void _startDeviceDiscovery() async {
    await _networkDiscoveryService.initialize();
    _networkDiscoveryService.onDeviceDiscovered.listen((ipAddress) async {
      if (!_connectedDevices.any((device) => device.id == ipAddress)) {
        try {
          final socket = await Socket.connect(ipAddress, 8080);
          final device = await _getDeviceInfo(socket);
          _connectedDevices.add(device);
        } catch (e) {
          if (kDebugMode) {
            print('Error connecting to device at $ipAddress: $e');
          }
        }
      }
    });
  }

  Future<DeviceInfo> _getDeviceInfo(Socket socket) async {
    final completer = Completer<DeviceInfo>();

    socket.listen((data) {
      try {
        final message = json.decode(String.fromCharCodes(data));
        if (message['type'] == 'HELLO') {
          final deviceInfo = DeviceInfo.fromJson(message['device']);
          deviceInfo.socket = socket;
          completer.complete(deviceInfo);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error decoding device info: $e');
        }
        completer.completeError(e);
      }
    }, onError: (error) {
      if (kDebugMode) {
        print('Socket error: $error');
      }
      completer.completeError(error);
    }, onDone: () {
      if (kDebugMode) {
        print('Socket closed');
      }
    });

    // Send HELLO message to get device info
    final device = await DeviceInfo.current();
    final hello = {
      'type': 'HELLO',
      'identifier': 'CLIPYBARA_NET_V1',
      'device': device.toJson(),
    };
    socket.add(utf8.encode(json.encode(hello)));

    return completer.future;
  }

  @override
  void onClose() {
    _clipboardCheckTimer?.cancel();
    super.onClose();
  }
}
