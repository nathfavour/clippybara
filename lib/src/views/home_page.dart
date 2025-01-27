import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/clipboard_controller.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Obx(() => SwitchListTile(
                  title: const Text('Enable Clipboard Sync'),
                  value: controller.isSharing,
                  onChanged: (value) {
                    if (value) {
                      controller.startSharing();
                    } else {
                      controller.stopSharing();
                    }
                  },
                )),
            const SizedBox(height: 16),
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
        ),
      ),
    );
  }
}
