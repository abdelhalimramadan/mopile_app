import 'package:flutter/material.dart';
import 'package:quit_smoking_app/services/notification_services.dart';
import 'package:quit_smoking_app/services/storage_services.dart';
import 'app.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await NotificationService.initialize();
   StorageService.initialize();

  runApp( SmokingQuitApp());
}