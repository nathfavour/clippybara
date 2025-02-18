import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../models/network_info.dart';
import '../models/device_info.dart';
import '../models/clipboard_data.dart';
import '../utils/helpers.dart';

class NetworkCoordinator {
  static const int _basePort = 8080;
  static const int _maxPortScan = 10;
  static const Duration _scanTimeout = Duration(seconds: 5);
  static const String _appIdentifier = 'CLIPYBARA_NET_V1';

  final Map<String, DeviceInfo> _connectedDevices = {};
  ServerSocket? _serverSocket;
  Timer? _discoveryTimer;
  Timer? _helloTimer;

  Future<void> initialize() async {
    await startServer();
    _startPeriodicDiscovery();
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
      if (kDebugMode) {
        print('New connection: ${socket.remoteAddress.address}');
      }
      _handleConnection(socket);
    });
  }

  Future<void> _handleConnection(Socket socket) async {
    try {
      socket.listen(
        (data) => _handleIncomingData(socket, data),
        onError: (error) => _handleSocketError(socket, error, socket),
        onDone: () => _handleDisconnection(socket),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error handling connection: $e');
      }
      _handleSocketError(socket, e, socket);
    }
  }

  Future<void> _handleIncomingData(Socket socket, List<int> data) async {
    try {
      final message = json.decode(String.fromCharCodes(data));

      if (message['identifier'] != _appIdentifier) {
        socket.close();
        return;
      }

      switch (message['type']) {
        case 'HELLO':
          final deviceInfo = DeviceInfo.fromJson(message['device']);
          deviceInfo.socket = socket; // Store the socket
          _connectedDevices[deviceInfo.id] = deviceInfo;
          if (kDebugMode) {
            print('Device connected: ${deviceInfo.name}');
          }

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
          if (kDebugMode) {
            print(
                'Received clipboard data: ${clipboardItem.content} from ${socket.remoteAddress.address}');
          }
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling connection: $e');
      }
      _handleSocketError(socket, e, socket);
    }
  }

  void _handleSocketError(Socket socket, dynamic error, Socket s) {
    if (kDebugMode) {
      print('Socket error: $error');
    }
    _handleDisconnection(socket);
  }

  void _handleDisconnection(Socket socket) {
    if (kDebugMode) {
      print('Device disconnected: ${socket.remoteAddress.address}');
    }
    socket.close();
    _connectedDevices.removeWhere((_, device) => device.socket == socket);
  }

  Future<Map<String, dynamic>> _getCurrentNetworkInfo() async {
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
    // No network migration for now
  }

  Future<void> broadcastClipboardData(ClipboardItem data) async {
    final message = {
      'type': 'CLIPBOARD_DATA',
      'identifier': _appIdentifier,
      'data': data.toJson(),
    };

    final encoded = utf8.encode(json.encode(message));

    for (var device in _connectedDevices.values) {
      try {
        device.socket?.add(encoded);
      } catch (e) {
        if (kDebugMode) {
          print('Error sending data to ${device.name}: $e');
        }
        _handleDisconnection(device.socket!);
      }
    }
  }

  Future<void> broadcastHello() async {
    final device = await DeviceInfo.current();
    final hello = {
      'type': 'HELLO',
      'identifier': _appIdentifier,
      'device': device.toJson(),
    };
    final encoded = utf8.encode(json.encode(hello));

    // Send hello to all known devices
    for (var device in _connectedDevices.values) {
      try {
        device.socket?.add(encoded);
      } catch (e) {
        if (kDebugMode) {
          print('Error sending hello to ${device.name}: $e');
        }
        _handleDisconnection(device.socket!);
      }
    }

    // Also, broadcast to the network
    for (int port = _basePort; port < _basePort + _maxPortScan; port++) {
      try {
        final socket = await Socket.connect('255.255.255.255', port,
            timeout: _scanTimeout);
        socket.add(encoded);
        await socket.close();
      } catch (e) {
        // Ignore errors during broadcast
      }
    }
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
