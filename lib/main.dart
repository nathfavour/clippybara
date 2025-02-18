import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:get/get.dart';
import 'src/controllers/clipboard_controller.dart';
import 'src/utils/helpers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool permissionsGranted = true;

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    permissionsGranted = await Helpers.requestPermissions();
  }

  Get.put(ClipboardController());
  runApp(const ClipybaraApp());
}

class ClipybaraApp extends StatelessWidget {
  const ClipybaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Clipybara running in the background'),
        ),
      ),
    );
  }
}
