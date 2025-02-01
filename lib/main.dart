import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'src/views/home_page.dart';
import 'src/controllers/clipboard_controller.dart';
import 'src/utils/helpers.dart';
import 'package:clippybara/theme/app_theme.dart';
import 'dart:io' show Platform, exit;
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool permissionsGranted = false;

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    permissionsGranted = await Helpers.requestPermissions();
    if (!permissionsGranted) {
      // Handle permissions not granted, possibly exit the app or show a dialog
      exit(0);
    }
  }

  Get.put(ClipboardController());
  runApp(const ClipybaraApp());
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
