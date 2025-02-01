class ClipboardItem {
  final String content;
  final DateTime timestamp;
  final String deviceId;

  ClipboardItem({
    required this.content,
    required this.timestamp,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() => {
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'deviceId': deviceId,
      };

  factory ClipboardItem.fromJson(Map<String, dynamic> json) => ClipboardItem(
        content: json['content'],
        timestamp: DateTime.parse(json['timestamp']),
        deviceId: json['deviceId'],
      );
}
