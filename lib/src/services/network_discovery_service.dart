import 'dart:async';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:flutter/foundation.dart';

class NetworkDiscoveryService {
  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  Stream<String> get onDeviceDiscovered => _controller.stream;
  static const String _serviceType = '_clipybara._tcp.local';
  MDnsClient? _mdnsClient;

  Future<void> initialize() async {
    await _startDiscovery();
  }

  Future<void> _startDiscovery() async {
    try {
      _mdnsClient = MDnsClient();
      await _mdnsClient!.start();

      _mdnsClient!
          .lookup<PtrResourceRecord>(
              ResourceRecordQuery.serverPointer(_serviceType))
          .listen((ptr) {
        _mdnsClient!
            .lookup<SrvResourceRecord>(
                ResourceRecordQuery.service(ptr.domainName))
            .listen((srv) {
          if (kDebugMode) {
            print('Found device: ${srv.target} at ${srv.target}:${srv.port}');
          }
          _controller.add(srv.target); // Use hostname as device ID
        });
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error starting mDNS discovery: $e');
      }
    }
  }

  Future<void> manualScan() async {
    // For mDNS, a manual scan is the same as the regular discovery
    await _startDiscovery();
  }

  void dispose() {
    _mdnsClient?.stop();
    _mdnsClient = null;
    _controller.close();
  }
}
