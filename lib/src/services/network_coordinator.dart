import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../models/network_info.dart';
import '../models/device_info.dart';
import '../models/clipboard_data.dart';

class NetworkCoordinator {
  static const int _basePort = 8080;
  static const int _maxPortScan = 10; // Will try ports 8080-8089
  static const Duration _scanTimeout = Duration(seconds: 5);
  static const String _appIdentifier = 'CLIPYBARA_NET_V1';

  final Map<String, DeviceInfo> _connectedDevices = {};
  ServerSocket? _serverSocket;
  Timer? _discoveryTimer;
  Timer? _helloTimer;

  Future<void> initialize() async {
    await startServer();
    _startPeriodicDiscovery();
    // Start periodic hello broadcast every 10 seconds.
    _helloTimer?.cancel();
    _helloTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      await broadcastHello();
    });
  }

  Future<void> startServer() async {
    for (int port = _basePort; port < _basePort + _maxPortScan; port++) {
      try {
        _serverSocket = await ServerSocket.bind(
          InternetAddress.anyIPv4,
          port,
          // removed unsupported name parameters
        );
        if (kDebugMode) {
          print('Server started on port $port');
        }
        _listenToConnections();
        break;
      } catch (e) {
        if (port == _basePort + _maxPortScan - 1) {
          throw Exception(
              'Failed to bind to any port in range $_basePort-${_basePort + _maxPortScan}');
        }
      }
    }
  }

  void _listenToConnections() {
    _serverSocket?.listen((socket) {
      socket.listen(
        (data) => _handleIncomingConnection(socket, data),
        onError: (error) => _handleSocketError(socket, error),
        onDone: () => _handleDisconnection(socket),
      );
    });
  }

  Future<void> _handleIncomingConnection(Socket socket, List<int> data) async {
    try {
      final message = json.decode(String.fromCharCodes(data));

      if (message['identifier'] != _appIdentifier) {
        socket.close();
        return;
      }

      switch (message['type']) {
        case 'HELLO':
          final deviceInfo = DeviceInfo.fromJson(message['device']);
          _connectedDevices[deviceInfo.id] = deviceInfo;

          final response = {
            'type': 'WELCOME',
            'identifier': _appIdentifier,
            'network': await _getCurrentNetworkInfo(),
            'devices': _connectedDevices.values.map((d) => d.toJson()).toList(),
          };

          socket.add(utf8.encode(json.encode(response)));
          break;

        case 'CLIPBOARD_DATA':
          final clipboardItem = ClipboardItem.fromJson(message['data']);
          // Handle clipboard data (e.g., update local clipboard)
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling connection: $e');
      }
      socket.close();
    }
  }

  void _handleSocketError(Socket socket, dynamic error) {
    if (kDebugMode) {
      print('Socket error: $error');
    }
    _handleDisconnection(socket);
  }

  void _handleDisconnection(Socket socket) {
    socket.close();
    // Remove device from connected list
    _connectedDevices.removeWhere((_, device) => device.socket == socket);
  }

  Future<Map<String, dynamic>> _getCurrentNetworkInfo() async {
    // Get current network details
    return {
      'port': _serverSocket?.port ?? _basePort,
      'deviceCount': _connectedDevices.length,
    };
  }

  void _startPeriodicDiscovery() {
    _discoveryTimer?.cancel();
    _discoveryTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _scanForNetworks();
    });
  }

  Future<void> _scanForNetworks() async {
    final networks = <NetworkInfo>[];

    for (int port = _basePort; port < _basePort + _maxPortScan; port++) {
      try {
        final socket = await Socket.connect('255.255.255.255', port,
            timeout: _scanTimeout);

        // Send hello message
        final hello = {
          'type': 'HELLO',
          'identifier': _appIdentifier,
          'device': await DeviceInfo.current(),
        };

        socket.add(utf8.encode(json.encode(hello)));

        await socket.close();
      } catch (_) {
        // Port scan timeout or error - continue to next port
        continue;
      }
    }

    // Analyze networks and potentially migrate
    _evaluateNetworkMigration(networks);
  }

  Future<void> _evaluateNetworkMigration(List<NetworkInfo> networks) async {
    if (networks.isEmpty) return;

    // Find network with most devices
    final bestNetwork =
        networks.reduce((a, b) => a.deviceCount > b.deviceCount ? a : b);

    // If we find a better network, migrate
    if (bestNetwork.deviceCount > _connectedDevices.length) {
      await _migrateToNetwork(bestNetwork);
    }
  }

  Future<void> _migrateToNetwork(NetworkInfo network) async {
    // Close current server
    await _serverSocket?.close();
    _serverSocket = null;

    // Connect to new network
    try {
      final socket = await Socket.connect(network.address, network.port);
      _handleIncomingConnection(socket, []); // Initialize connection
    } catch (e) {
      print('Migration failed: $e');
      // Restart own server as fallback
      await startServer();
    }
  }

  Future<void> broadcastClipboardData(ClipboardItem data) async {
    final message = {
      'type': 'CLIPBOARD_DATA',
      'identifier': _appIdentifier,
      'data': data.toJson(),
    };

    final encoded = utf8.encode(json.encode(message));

    for (var device in _connectedDevices.values) {
      device.socket?.add(encoded);
    }
  }

  Future<void> broadcastHello() async {
    // Build hello message including current device info.
    final device = await DeviceInfo.current();
    final hello = {
      'type': 'HELLO',
      'identifier': _appIdentifier,
      'device': device.toJson(),
    };
    final encoded = utf8.encode(json.encode(hello));
    // Send hello message on all available connections.
    for (var device in _connectedDevices.values) {
      device.socket?.add(encoded);
    }
    // Optionally, log the broadcast.
    if (kDebugMode) print('Broadcasted HELLO: ${device.name}');
  }

  void dispose() {
    _serverSocket?.close();
    _discoveryTimer?.cancel();
    _helloTimer?.cancel();
    for (var device in _connectedDevices.values) {
      device.socket?.close();
    }
    _connectedDevices.clear();
  }
}
