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
    // Remove page initialization here to avoid using BuildContext before ready.
  }

  @override
  Widget build(BuildContext context) {
    // Build pages using context (inherited widgets available)
    final pages = [
      _buildClipboardTab(),
      _buildDevicesTab(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clipybara'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.to(() => const SettingsPage()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Optional: allow manual clipboard sharing.
          // Otherwise, live sync works automatically.
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
        return; // ensure a Future<void> is returned.
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
                    // Reuse existing ClipboardCard widget.
                    child: /* ...existing ClipboardCard code... */ Container(
                      // Replace with your ClipboardCard widget.
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
        onRefresh: () async {
          // Optionally trigger a rediscovery.
        },
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
