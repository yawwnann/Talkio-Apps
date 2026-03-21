import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/storage_service.dart';

/// Main Function
/// Entry point aplikasi dengan inisialisasi services
void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage service
  await StorageService.init();
  
  // Run app with Riverpod provider scope
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}