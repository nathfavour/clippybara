import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../models/network_info.dart';
import '../models/device_info.dart';
import '../models/clipboard_data.dart';
import '../utils/encryption_helper.dart';

class NetworkCoordinator {
  static const int _basePort = 8080;
  static const int _maxPortScan = 10; // Will try ports 8080-8089
  static const Duration _scanTimeout = Duration(seconds: 5);
  static const String _appIdentifier = 'CLIPYBARA_NET_V1';

  final EncryptionHelper _encryption = EncryptionHelper();
  final Map<String, DeviceInfo> _connectedDevices = {};
  ServerSocket? _serverSocket;
  Timer? _discoveryTimer;

  final StreamController<Map<String, DeviceInfo>> _devicesController =
      StreamController<Map<String, DeviceInfo>>.broadcast();

  final StreamController<ClipboardItem> _clipboardDataController =
      StreamController<ClipboardItem>.broadcast();

  Stream<Map<String, DeviceInfo>> get devicesStream =>
      _devicesController.stream;
  Stream<ClipboardItem> get clipboardDataStream =>
      _clipboardDataController.stream;

  Future<void> initialize() async {
    await startServer();
    _startPeriodicDiscovery();
  }

  Future<void> startServer() async {
    for (int port = _basePort; port < _basePort + _maxPortScan; port++) {
      try {
        _serverSocket = await ServerSocket.bind(
          InternetAddress.anyIPv4,
          port,
        );
        print('Server started on port $port');
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
      final decrypted = await _encryption.decrypt(data);
      final message = json.decode(decrypted);

      if (message['identifier'] != _appIdentifier) {
        socket.close();
        return;
      }

      switch (message['type']) {
        case 'HELLO':
          final deviceInfo = DeviceInfo.fromJson(message['device']);
          _connectedDevices[deviceInfo.id] = deviceInfo;
          _devicesController.add(Map.from(_connectedDevices));

          final response = {
            'type': 'WELCOME',
            'identifier': _appIdentifier,
            'network': await _getCurrentNetworkInfo(),
            'devices': _connectedDevices.values.map((d) => d.toJson()).toList(),
          };

          final encrypted = await _encryption.encrypt(json.encode(response));
          socket.add(encrypted);
          break;

        case 'CLIPBOARD_DATA':
          final clipboardItem = ClipboardItem.fromJson(message['data']);
          _clipboardDataController.add(clipboardItem);
          break;
      }
    } catch (e) {
      print('Error handling connection: $e');
      socket.close();
    }
  }

  void _handleSocketError(Socket socket, dynamic error) {
    print('Socket error: $error');
    _handleDisconnection(socket);
  }

  void _handleDisconnection(Socket socket) {
    socket.close();
    // Remove device from connected list
    _connectedDevices.removeWhere((_, device) => device.socket == socket);
    _devicesController.add(Map.from(_connectedDevices));
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

        final encrypted = await _encryption.encrypt(json.encode(hello));
        socket.add(encrypted);

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

    final encrypted = await _encryption.encrypt(json.encode(message));

    for (var device in _connectedDevices.values) {
      device.socket?.add(encrypted);
    }
  }

  void dispose() {
    _serverSocket?.close();
    _discoveryTimer?.cancel();
    _devicesController.close();
    _clipboardDataController.close();
    for (var device in _connectedDevices.values) {
      device.socket?.close();
    }
    _connectedDevices.clear();
  }
}
