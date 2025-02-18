import 'dart:async';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkDiscoveryService {
  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  Stream<String> get onDeviceDiscovered => _controller.stream;
  static const int discoveryPort = 9000; // Port for UDP discovery
  final NetworkInfo _networkInfo = NetworkInfo();

  Future<void> initialize() async {
    startListening();
  }

  Future<void> startListening() async {
    try {
      final String? wifiIP = await _networkInfo.getWifiIP();
      if (wifiIP == null) {
        if (kDebugMode) {
          print("WiFi is not connected. Cannot start discovery.");
        }
        return;
      }

      final InternetAddress listenAddress =
          InternetAddress.anyIPv4; // Listen on all interfaces
      final MulticastSocket socket =
          await MulticastSocket.bind(listenAddress, discoveryPort);

      socket.joinMulticast(InternetAddress('224.0.0.1')); // Multicast group

      socket.listen((event) {
        final datagram = socket.receive();
        if (datagram != null) {
          final message = String.fromCharCodes(datagram.data);
          if (kDebugMode) {
            print('Received: ${message} from ${datagram.address.address}');
          }
          _controller.add(datagram.address.address); // Use IP as device ID
        }
      });

      if (kDebugMode) {
        print('Listening for UDP broadcasts on port $discoveryPort');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error starting UDP listener: $e');
      }
    }
  }

  Future<void> manualScan() async {
    // Broadcast a UDP message to discover devices
    String? wifiIP = await _networkInfo.getWifiIP();
    if (wifiIP == null) {
      if (kDebugMode) {
        print("WiFi is not connected. Cannot start manual scan.");
      }
      return;
    }

    try {
      final Socket socket = await Socket.connect(
          '255.255.255.255', discoveryPort); // Broadcast address
      final message = "CLIPYBARA_DISCOVERY"; // Simple discovery message
      socket.write(message);
      await socket.flush();
      await socket.close();
      if (kDebugMode) {
        print('Sent UDP discovery message');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending UDP broadcast: $e');
      }
    }
  }

  void dispose() {
    _controller.close();
  }
}
