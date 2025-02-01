import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'src/views/home_page.dart';
import 'src/controllers/clipboard_controller.dart';
import 'src/utils/helpers.dart';
import 'package:clippybara/theme/app_theme.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool permissionsGranted = true;

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    permissionsGranted = await Helpers.requestPermissions();
  }

  Get.put(ClipboardController());
  runApp(
      permissionsGranted ? const ClipybaraApp() : const PermissionErrorApp());
}

class ClipybaraApp extends StatelessWidget {
  const ClipybaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Clipybara',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Supports fast live theme switching
      home: const HomePage(),
    );
  }
}

class PermissionErrorApp extends StatelessWidget {
  const PermissionErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Permissions Required',
      theme: AppTheme.lightTheme,
      home: Scaffold(
        appBar: AppBar(title: const Text('Permissions Required')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'The app requires all necessary permissions to run properly. '
                  'Please grant the required permissions in your device settings and restart the app.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    bool granted = await Helpers.requestPermissions();
                    if (granted) {
                      // Restart the app upon successful permission granting
                      runApp(const ClipybaraApp());
                    }
                  },
                  child: const Text('Retry Permissions'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
