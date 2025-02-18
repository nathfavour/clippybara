import 'package:flutter/material.dart';
import '../src/models/clipboard_data.dart';

class ClipboardCard extends StatelessWidget {
  final ClipboardItem item;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const ClipboardCard({
    super.key,
    required this.item,
    required this.onCopy,
    required this.onShare,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(item.content),
        subtitle: Text(item.timestamp.toLocal().toString()),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: onCopy,
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: onShare,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
