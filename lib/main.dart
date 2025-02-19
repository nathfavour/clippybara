import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:get/get.dart';
import 'src/controllers/clipboard_controller.dart';
import 'src/utils/helpers.dart';
import 'src/views/home_page.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool permissionsGranted = true;

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    permissionsGranted = await Helpers.requestPermissions();
    // Request battery optimization exemption
    await Helpers.requestBatteryOptimization();
  }

  Get.put(ClipboardController());
  runApp(const ClipybaraApp());
}

class ClipybaraApp extends StatelessWidget {
  const ClipybaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Clippybara',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const HomePage(),
    );
  }
}
