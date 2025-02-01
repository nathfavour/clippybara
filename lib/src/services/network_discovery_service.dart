import 'dart:async';
import 'package:multicast_dns/multicast_dns.dart';

class NetworkDiscoveryService {
  static const String _serviceName = '_clipybara._tcp';

  MDnsClient? _mdnsClient;
  final StreamController<String> _deviceDiscoveredController =
      StreamController<String>.broadcast();
  final Map<String, String> _connectedDevices = {};

  Stream<String> get onDeviceDiscovered => _deviceDiscoveredController.stream;
  Map<String, String> get connectedDevices => _connectedDevices;

  Future<void> initialize() async {
    await startDiscovery();
  }

  Future<void> startDiscovery() async {
    if (_mdnsClient != null) return;

    try {
      _mdnsClient = MDnsClient();
      await _mdnsClient!.start();
      await _discoverServices();
    } catch (e) {
      print('Error starting network discovery: $e');
    }
  }

  Future<void> _discoverServices() async {
    await for (final PtrResourceRecord ptr in _mdnsClient!
        .lookup<PtrResourceRecord>(
            ResourceRecordQuery.serverPointer(_serviceName))) {
      if (!_connectedDevices.containsKey(ptr.domainName)) {
        final String deviceName = await _getDeviceName(ptr.domainName);
        _connectedDevices[ptr.domainName] = deviceName;
        _deviceDiscoveredController.add(ptr.domainName);
      }
    }
  }

  Future<String> _getDeviceName(String address) async {
    try {
      final srv = await _mdnsClient!
          .lookup<SrvResourceRecord>(ResourceRecordQuery.service(address))
          .first;
      return srv.target;
    } catch (e) {
      return 'Device at $address';
    }
  }

  Future<void> stop() async {
    if (_mdnsClient != null) {
      _mdnsClient!.stop();
      _mdnsClient = null;
    }
  }

  void dispose() {
    stop();
    _deviceDiscoveredController.close();
  }
}
