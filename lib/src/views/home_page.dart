import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/clipboard_controller.dart';
import '../views/settings_page.dart';
import '../../widgets/custom_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClipboardController>();

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            // Tablet/Desktop Layout
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Expanded(child: _buildSyncSection(controller, context)),
                  const VerticalDivider(),
                  Expanded(child: _buildClipboardSection(controller, context)),
                ],
              ),
            );
          } else {
            // Mobile Layout
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSyncSection(controller, context),
                  const SizedBox(height: 16),
                  _buildClipboardSection(controller, context),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildSyncSection(
      ClipboardController controller, BuildContext context) {
    return Column(
      children: [
        CustomSwitchTile(
          title: 'Enable Clipboard Sync',
          value: controller.isSharing,
          onChanged: (value) {
            if (value) {
              controller.startSharing();
            } else {
              controller.stopSharing();
            }
          },
        ),
        const SizedBox(height: 16),
        Obx(() => SwitchListTile(
              title: const Text('Use WiFi for Sync'),
              value: controller.useWifi,
              onChanged: (value) {
                controller.setUseWifi(value);
              },
            )),
      ],
    );
  }

  Widget _buildClipboardSection(
      ClipboardController controller, BuildContext context) {
    return Column(
      children: [
        Obx(() => Text(
              'Current Clipboard: ${controller.clipboardContent}',
              style: Theme.of(context).textTheme.bodyLarge,
            )),
        const SizedBox(height: 16),
        Expanded(
          child: Obx(() => ListView.builder(
                itemCount: controller.connectedDevices.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(controller.connectedDevices[index]),
                    leading: const Icon(Icons.devices),
                  );
                },
              )),
        ),
      ],
    );
  }
}
