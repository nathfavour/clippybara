import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_widget.dart';
import '../controllers/clipboard_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClipboardController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        theme,
                        'Sync Settings',
                        [
                          CustomSwitchTile(
                            title: 'Enable Clipboard Sync',
                            value: controller.syncEnabled,
                            onChanged: controller.setSyncEnabled,
                          ),
                          CustomSwitchTile(
                            title: 'Auto-connect to Devices',
                            value: controller.autoConnect,
                            onChanged: controller.setAutoConnect,
                          ),
                          CustomSwitchTile(
                            title: 'Use WiFi for Sync',
                            value: controller.useWifi,
                            onChanged: (value) {
                              controller.setUseWifi(value);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSection(
                        theme,
                        'Notifications',
                        [
                          CustomSwitchTile(
                            title: 'Enable Notifications',
                            value: controller.notificationsEnabled,
                            onChanged: controller.setNotificationsEnabled,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSection(
                        theme,
                        'Clipboard History',
                        [
                          ListTile(
                            title: Text('Clear Clipboard History',
                                style: theme.textTheme.bodyLarge),
                            trailing: TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Clear History'),
                                    content: const Text(
                                        'Are you sure you want to clear your clipboard history?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          controller.clearHistory();
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Clear'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text('Clear'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSection(
                        theme,
                        'Connected Devices',
                        [
                          Obx(() => controller.connectedDevices.isEmpty
                              ? const ListTile(
                                  title: Text('No devices connected'),
                                )
                              : Column(
                                  children: controller.connectedDevices
                                      .map((device) => ListTile(
                                            title: Text(device.name),
                                            subtitle: Text(
                                                'Last seen: ${_formatDateTime(device.lastSeen)}'),
                                            leading: const Icon(Icons.devices),
                                          ))
                                      .toList(),
                                )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: theme.textTheme.titleLarge,
          ),
        ),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
