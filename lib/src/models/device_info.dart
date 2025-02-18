import 'dart:io';
import '../utils/helpers.dart';

class DeviceInfo {
  final String id;
  final String name;
  final DateTime lastSeen;
  Socket? socket; // Make socket non-final

  DeviceInfo({
    required this.id,
    required this.name,
    DateTime? lastSeen,
    this.socket,
  }) : lastSeen = lastSeen ?? DateTime.now();

  static Future<DeviceInfo> current() async {
    final id = await Helpers.getDeviceId();
    final name = await Helpers.getDeviceName();
    return DeviceInfo(id: id, name: name);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'lastSeen': lastSeen.toIso8601String(),
      };

  factory DeviceInfo.fromJson(Map<String, dynamic> json) => DeviceInfo(
        id: json['id'],
        name: json['name'],
        lastSeen: DateTime.parse(json['lastSeen']),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceInfo && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
