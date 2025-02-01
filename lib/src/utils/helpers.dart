import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class Helpers {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static String? _deviceId;
  static String? _deviceName;

  static Future<bool> requestPermissions() async {
    if (kIsWeb) return true;

    if (Platform.isAndroid || Platform.isIOS) {
      var permissions = <Permission>[
        Permission.location,
        Permission.storage,
        Permission.notification,
      ];

      // Add Nearby Devices permission for Android 12 and above
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        if (androidInfo.version.sdkInt >= 31) {
          permissions.add(Permission.nearbyWifiDevices);
          permissions.add(Permission.bluetoothScan);
          permissions.add(Permission.bluetoothConnect);
        }
      }

      // Request all required permissions
      Map<Permission, PermissionStatus> statuses = await permissions.request();

      // Check if any permission was denied
      return !statuses.values.any((status) => !status.isGranted);
    }

    // Desktop platforms don't need explicit permissions
    return true;
  }

  static Future<String> getDeviceId() async {
    if (_deviceId != null) return _deviceId!;

    if (kIsWeb) {
      _deviceId = 'web_${DateTime.now().millisecondsSinceEpoch}';
    } else if (Platform.isAndroid) {
      final info = await _deviceInfo.androidInfo;
      _deviceId = info.id;
    } else if (Platform.isIOS) {
      final info = await _deviceInfo.iosInfo;
      _deviceId = info.identifierForVendor;
    } else {
      final package = await PackageInfo.fromPlatform();
      _deviceId =
          '${Platform.operatingSystem}_${package.appName}_${DateTime.now().millisecondsSinceEpoch}';
    }

    return _deviceId!;
  }

  static Future<String> getDeviceName() async {
    if (_deviceName != null) return _deviceName!;

    if (kIsWeb) {
      _deviceName = 'Web Browser';
    } else if (Platform.isAndroid) {
      final info = await _deviceInfo.androidInfo;
      _deviceName = '${info.brand} ${info.model}';
    } else if (Platform.isIOS) {
      final info = await _deviceInfo.iosInfo;
      _deviceName = info.name;
    } else {
      _deviceName = Platform.operatingSystem;
    }

    return _deviceName!;
  }

  static void showError(String message, {String? title}) {
    // Implementation can be added based on your preferred error display method
  }

  static void showSuccess(String message, {String? title}) {
    // Implementation can be added based on your preferred success display method
  }
}
