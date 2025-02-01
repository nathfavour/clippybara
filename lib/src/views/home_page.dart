import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/clipboard_controller.dart';
import '../views/settings_page.dart';
import '../../widgets/clipboard_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClipboardController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clippybara'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.to(() => const SettingsPage()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateClipDialog(context, controller),
        child: const Icon(Icons.add),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return _buildTabletLayout(controller, theme);
          } else {
            return _buildMobileLayout(controller, theme);
          }
        },
      ),
    );
  }

  void _showCreateClipDialog(
      BuildContext context, ClipboardController controller) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Clip'),
        content: TextField(
          controller: textController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Enter text to share...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                controller.addClipboardItem(textController.text);
                controller.shareWithConnectedDevices(textController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(ClipboardController controller, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildClipboardSection(controller, theme),
        ),
        const VerticalDivider(),
        Expanded(
          flex: 1,
          child: _buildDeviceSection(controller, theme),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(ClipboardController controller, ThemeData theme) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: const [
              Tab(text: 'Clipboard'),
              Tab(text: 'Devices'),
            ],
            labelStyle: theme.textTheme.titleMedium,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildClipboardSection(controller, theme),
                _buildDeviceSection(controller, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClipboardSection(
      ClipboardController controller, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Clipboard',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Obx(() => SelectableText(
                        controller.clipboardContent.isEmpty
                            ? 'No content'
                            : controller.clipboardContent,
                        style: theme.textTheme.bodyLarge,
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Clipboard History',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: controller.clipboardHistory.length,
                  itemBuilder: (context, index) {
                    final item = controller.clipboardHistory[index];
                    return ClipboardCard(
                      item: item,
                      onCopy: () => controller.copyToClipboard(item.content),
                      onShare: () =>
                          controller.shareWithConnectedDevices(item.content),
                      onDelete: () => controller.removeFromHistory(index),
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceSection(ClipboardController controller, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sync Status',
                    style: theme.textTheme.titleMedium,
                  ),
                  Obx(() => Chip(
                        label: Text(
                          controller.isSharing ? 'Active' : 'Disabled',
                        ),
                        backgroundColor: controller.isSharing
                            ? Colors.green.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.2),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Connected Devices',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() => controller.connectedDevices.isEmpty
                ? Center(
                    child: Text(
                      'No devices connected',
                      style: theme.textTheme.bodyLarge,
                    ),
                  )
                : ListView.builder(
                    itemCount: controller.connectedDevices.length,
                    itemBuilder: (context, index) {
                      final device = controller.connectedDevices[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.devices),
                          title: Text(device.name),
                          subtitle: Text(
                              'Last seen: ${_formatDateTime(device.lastSeen)}'),
                        ),
                      );
                    },
                  )),
          ),
        ],
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
