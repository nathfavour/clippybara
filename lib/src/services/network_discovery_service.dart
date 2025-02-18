import 'dart:async';

class NetworkDiscoveryService {
  // A stream to mimic discovered device IDs.
  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  // Exposed stream for device discovery.
  Stream<String> get onDeviceDiscovered => _controller.stream;

  Future<void> initialize() async {
    // Stub: simulate discovery after a delay.
    Future.delayed(const Duration(seconds: 1), () {
      _controller.add("stub-device-001");
    });
  }

  void dispose() {
    _controller.close();
  }
}
