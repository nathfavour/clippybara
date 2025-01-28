import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'src/views/home_page.dart';
import 'src/controllers/clipboard_controller.dart';
import 'src/utils/helpers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool permissionsGranted = await Helpers.requestPermissions();
  if (!permissionsGranted) {
    // Handle permissions not granted
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
