import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/clipboard_controller.dart';
import '../views/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ClipboardController controller = Get.find<ClipboardController>();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildClipboardTab(),
      _buildDevicesTab(),
    ];
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
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              final TextEditingController textController =
                  TextEditingController();
              return AlertDialog(
                title: const Text('Add to Clipboard'),
                content: TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: 'Enter text',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.copyToClipboard(textController.text);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.content_copy), label: 'Clipboard'),
          BottomNavigationBarItem(icon: Icon(Icons.devices), label: 'Devices'),
        ],
      ),
    );
  }

  Widget _buildClipboardTab() {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: () async {
        controller.copyToClipboard(controller.clipboardContent);
        return;
      },
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text('Current Clipboard', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(() => SelectableText(
                    controller.clipboardContent.isEmpty
                        ? 'No content'
                        : controller.clipboardContent,
                    style: theme.textTheme.bodyLarge,
                  )),
            ),
          ),
          const SizedBox(height: 16),
          Text('Clipboard History', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Obx(() => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.clipboardHistory.length,
                itemBuilder: (context, index) {
                  final item = controller.clipboardHistory[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                      child: Text(item.content),
                    ),
                  );
                },
              )),
        ],
      ),
    );
  }

  Widget _buildDevicesTab() {
    final theme = Theme.of(context);
    return Obx(() {
      return RefreshIndicator(
        onRefresh: () async {},
        child: controller.connectedDevices.isEmpty
            ? Center(
                child: Text('No devices connected',
                    style: theme.textTheme.bodyLarge))
            : ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: controller.connectedDevices.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final device = controller.connectedDevices[index];
                  return ListTile(
                    leading: const Icon(Icons.devices),
                    title: Text(device.name),
                    subtitle:
                        Text('Last seen: ${_formatDateTime(device.lastSeen)}'),
                  );
                },
              ),
      );
    });
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
