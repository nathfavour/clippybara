class ClipboardData {
  final String content;
  final DateTime timestamp;
  final String deviceId;

  ClipboardData({
    required this.content,
    required this.timestamp,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() => {
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'deviceId': deviceId,
      };

  factory ClipboardData.fromJson(Map<String, dynamic> json) => ClipboardData(
        content: json['content'],
        timestamp: DateTime.parse(json['timestamp']),
        deviceId: json['deviceId'],
      );
}
