import 'package:network_info_plus/network_info_plus.dart';
import '../models/clipboard_data.dart';
import 'network_coordinator.dart';
import 'dart:async';

class WifiService {
  final NetworkCoordinator _coordinator = NetworkCoordinator();
  final _networkInfo = NetworkInfo();
  StreamSubscription? _devicesSubscription;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _coordinator.initialize();
      _isInitialized = true;
    } catch (e) {
      print('Error initializing network coordinator: $e');
      await Future.delayed(const Duration(seconds: 5));
      await initialize();
    }
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
