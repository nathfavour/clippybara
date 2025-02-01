import 'dart:async';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:multicast_dns/multicast_dns.dart';
import '../models/clipboard_data.dart';

class NetworkDiscoveryService {
  static const String _serviceName = '_clipybara._tcp';
  final NetworkInfo _networkInfo = NetworkInfo();
  MDnsClient? _mdnsClient;
  final StreamController<String> _deviceDiscoveredController =
      StreamController<String>.broadcast();
  final Map<String, String> _connectedDevices = {};
  String? _deviceId;

  Stream<String> get onDeviceDiscovered => _deviceDiscoveredController.stream;
  Map<String, String> get connectedDevices => _connectedDevices;

  Future<void> initialize() async {
    _deviceId = await _getDeviceIdentifier();
    await startDiscovery();
  }

  Future<void> startDiscovery() async {
    if (_mdnsClient != null) return;

    try {
      _mdnsClient = MDnsClient();
      await _mdnsClient!.start();

      // Advertise our service
      await _advertiseService();

      // Listen for other devices
      await _discoverServices();
    } catch (e) {
      print('Error starting network discovery: $e');
    }
  }

  Future<void> _advertiseService() async {
    final String? ipAddress = await _networkInfo.getWifiIP();
    if (ipAddress == null) return;

    final serviceInstance = await _mdnsClient!.lookup<PtrResourceRecord>(
      ResourceRecordQuery.serverPointer(_serviceName),
    );

    if (serviceInstance.isEmpty) {
      await _mdnsClient!.registerResourceRecord(SrvResourceRecord(
        _serviceName,
        4500,
        0,
        0,
        8080,
        ipAddress,
      ));
    }
  }

  Future<void> _discoverServices() async {
    await for (final PtrResourceRecord ptr in _mdnsClient!
        .lookup<PtrResourceRecord>(
            ResourceRecordQuery.serverPointer(_serviceName))) {
      final String deviceAddress = ptr.domainName;
      if (!_connectedDevices.containsKey(deviceAddress)) {
        _connectedDevices[deviceAddress] = await _getDeviceName(deviceAddress);
        _deviceDiscoveredController.add(deviceAddress);
      }
    }
  }

  Future<String> _getDeviceIdentifier() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return Platform.localHostname;
    } else {
      return Platform.operatingSystem +
          '_' +
          DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  Future<String> _getDeviceName(String address) async {
    // Implement device name resolution logic
    return 'Device at $address';
  }

  Future<void> stop() async {
    await _mdnsClient?.stop();
    _mdnsClient = null;
  }

  void dispose() {
    stop();
    _deviceDiscoveredController.close();
  }
}
