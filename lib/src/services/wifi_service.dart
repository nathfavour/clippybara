import 'package:wifi_iot/wifi_iot.dart';
import '../models/clipboard_data.dart';
import 'dart:convert';
// Modified import to include ServerSocket
import 'dart:io' show Platform, InternetAddress, Socket, ServerSocket;

class WifiService {
  Socket? _serverSocket;
  List<Socket> _clientSockets = [];
  static const int _port = 8080;

  Future<bool> connectToWifi(String ssid, String password) async {
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        await WiFiForIoTPlugin.disconnect();
        await WiFiForIoTPlugin.connect(
          ssid,
          password: password,
          security: NetworkSecurity.WPA,
        );
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  Future<void> disconnectWifi() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await WiFiForIoTPlugin.disconnect();
    } else {
      // Handle desktop platforms
    }
  }

  Future<List<WifiNetwork>> getAvailableNetworks() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return await WiFiForIoTPlugin.loadWifiList();
    } else {
      // Handle desktop platforms or return an empty list
      return [];
    }
  }

  Future<void> startWifiSharing() async {
    try {
      final server = await ServerSocket.bind(InternetAddress.anyIPv4, _port);
      _serverSocket = server as Socket?;

      server.listen((socket) {
        _clientSockets.add(socket);
        socket.listen(
          (data) => _handleIncomingData(data, socket),
          onDone: () => _handleDisconnect(socket),
          onError: (error) => _handleError(error, socket),
        );
      });
    } catch (e) {
      print('Error starting WiFi sharing: $e');
    }
  }

  void _handleIncomingData(List<int> data, Socket socket) {
    try {
      final String jsonStr = utf8.decode(data);
      final Map<String, dynamic> json = jsonDecode(jsonStr);
      final item = ClipboardItem.fromJson(json);
      // Handle received clipboard item
      // You can add a callback or stream here to notify the controller
    } catch (e) {
      print('Error handling incoming data: $e');
    }
  }

  void _handleDisconnect(Socket socket) {
    _clientSockets.remove(socket);
    socket.destroy();
  }

  void _handleError(dynamic error, Socket socket) {
    print('Socket error: $error');
    _handleDisconnect(socket);
  }

  Future<void> stopWifiSharing() async {
    for (var socket in _clientSockets) {
      socket.destroy();
    }
    _clientSockets.clear();
    await _serverSocket?.close();
    _serverSocket = null;
  }

  Future<void> sendData(ClipboardItem data) async {
    final String jsonStr = jsonEncode(data.toJson());
    final List<int> bytes = utf8.encode(jsonStr);

    for (var socket in _clientSockets) {
      try {
        socket.add(bytes);
        await socket.flush();
      } catch (e) {
        print('Error sending data to socket: $e');
        _handleDisconnect(socket);
      }
    }
  }
}
