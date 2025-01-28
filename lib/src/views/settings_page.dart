import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/clipboard_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClipboardController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Obx(() => SwitchListTile(
                  title: const Text('Use WiFi for Sync'),
                  value: controller.useWifi,
                  onChanged: (value) {
                    controller.setUseWifi(value);
                  },
                )),
          ],
        ),
      ),
    );
  }
}
