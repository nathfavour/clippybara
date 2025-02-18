import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/device_info.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  final NetworkDiscoveryService _discoveryService = NetworkDiscoveryService();
  final FavoritesManager _favoritesManager = Get.put(FavoritesManager());
  final RxList<DeviceInfo> _discoveredDevices = <DeviceInfo>[].obs;

  @override
  void initState() {
    super.initState();
    // Start scanning on load
    _startScanning();
    // Listen to newly discovered devices
    _discoveryService.onDeviceDiscovered.listen((deviceId) async {
      // Create a DeviceInfo with a dummy name or query for additional details
      var device = DeviceInfo(
          id: deviceId,
          name: 'Device ${_discoveredDevices.length + 1}',
          lastSeen: DateTime.now());
      if (!_discoveredDevices.any((d) => d.id == device.id)) {
        _discoveredDevices.add(device);
      }
    });
  }

  Future<void> _startScanning() async {
    await _discoveryService.initialize();
  }

  @override
  void dispose() {
    _discoveryService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              _discoveredDevices.clear();
              await _startScanning();
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (_discoveredDevices.isEmpty) {
                return const Center(child: Text('No devices found'));
              }
              return ListView.builder(
                itemCount: _discoveredDevices.length,
                itemBuilder: (context, index) {
                  final device = _discoveredDevices[index];
                  return ListTile(
                    title: Text(device.name),
                    subtitle: Text(device.id),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Implement connection logic
                          },
                          child: const Text('Connect'),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.star_border),
                          onPressed: () {
                            _favoritesManager.addFavorite(device);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
          Container(
            color: Colors.grey[200],
            height: 100,
            child: Obx(() {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _favoritesManager.favorites.length,
                itemBuilder: (context, index) {
                  final fav = _favoritesManager.favorites[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Chip(
                      label: Text(fav.name),
                      deleteIcon: const Icon(Icons.close),
                      onDeleted: () {
                        _favoritesManager.removeFavorite(fav.id);
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
