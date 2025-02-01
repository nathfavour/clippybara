class NetworkInfo {
  final String address;
  final int port;
  final int deviceCount;
  final DateTime discovered;

  NetworkInfo({
    required this.address,
    required this.port,
    required this.deviceCount,
    DateTime? discovered,
  }) : discovered = discovered ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'address': address,
        'port': port,
        'deviceCount': deviceCount,
        'discovered': discovered.toIso8601String(),
      };

  factory NetworkInfo.fromJson(Map<String, dynamic> json) => NetworkInfo(
        address: json['address'],
        port: json['port'],
        deviceCount: json['deviceCount'],
        discovered: DateTime.parse(json['discovered']),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkInfo &&
          runtimeType == other.runtimeType &&
          address == other.address &&
          port == other.port;

  @override
  int get hashCode => address.hashCode ^ port.hashCode;
}
