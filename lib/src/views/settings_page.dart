import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_widget.dart';
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    CustomSwitchTile(
                      title: 'Use WiFi for Sync',
                      value: controller.useWifi,
                      onChanged: (value) {
                        controller.setUseWifi(value);
                      },
                    ),
                    // Add more settings here if needed
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
