import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_widget.dart';
import '../controllers/clipboard_controller.dart';
import 'package:clippybara/src/utils/helpers.dart';

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
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      theme,
                      'Appearance',
                      [
                        ListTile(
                          leading: const Icon(Icons.brightness_4),
                          title: const Text('Theme Mode'),
                          trailing: DropdownButton<ThemeMode>(
                            value: Get.isDarkMode
                                ? ThemeMode.dark
                                : ThemeMode.light,
                            items: const [
                              DropdownMenuItem(
                                value: ThemeMode.light,
                                child: Text('Light'),
                              ),
                              DropdownMenuItem(
                                value: ThemeMode.dark,
                                child: Text('Dark'),
                              ),
                            ],
                            onChanged: (ThemeMode? mode) {
                              if (mode != null) {
                                Get.changeThemeMode(mode);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
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
                          leading: const Icon(Icons.history),
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
                                    ElevatedButton(
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
                                leading: Icon(Icons.info),
                                title: Text('No devices connected'),
                              )
                            : Column(
                                children: controller.connectedDevices
                                    .map((device) => ListTile(
                                          leading: const Icon(Icons.devices),
                                          title: Text(device.name),
                                          subtitle: Text(
                                              'Last seen: ${_formatDateTime(device.lastSeen)}'),
                                        ))
                                    .toList(),
                              )),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      theme,
                      'Background Service',
                      [
                        ListTile(
                          leading: const Icon(Icons.battery_std),
                          title: const Text('Disable Battery Optimization'),
                          subtitle:
                              const Text('Allow app to run in background'),
                          trailing: ElevatedButton(
                            onPressed: () async {
                              bool success =
                                  await Helpers.requestBatteryOptimization();
                              final snackBar = SnackBar(
                                content: Text(success
                                    ? 'Battery optimization disabled.'
                                    : 'Request failed.'),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            },
                            child: const Text('Request'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              ...children.map((child) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: child,
                  )),
            ],
          ),
        ),
      ),
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
