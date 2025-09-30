import 'package:attendance_app/constants/app_colors.dart';
import 'package:attendance_app/services/auth_services.dart';
import 'package:attendance_app/services/geo_fence_services.dart';
import 'package:attendance_app/services/language_controller.dart';
import 'package:attendance_app/services/offline_local_storage.dart';
import 'package:attendance_app/services/superbase_services.dart';
import 'package:attendance_app/view/screens/login/login_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: 'https://cpvyypvivqwjyxtmqeli.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNwdnl5cHZpdnF3anl4dG1xZWxpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY4ODgzNTQsImV4cCI6MjA3MjQ2NDM1NH0.IF-UZKeo8HcBQ2XElB3j0HxfQVFWcXw8S1HvRovcsvM',
    );
 
  } catch (e) {
    print('Error initializing Supabase: $e');
  }

  // Initialize services in correct order
  try {
    Get.put(SupabaseService());
    Get.put(GeoFenceService()); // Moved before OfflineLocalStorageService
    Get.put(OfflineLocalStorageService());
    await Get.find<OfflineLocalStorageService>().init(); // Ensure async init
    Get.put(AuthService());
    Get.put(LanguageController());
  } catch (e) {
    print('Error initializing services: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: kWhite),
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
  translations: AppTranslations(),
  locale: const Locale('en', 'US'),
  fallbackLocale: const Locale('en', 'US'),
      themeMode: ThemeMode.light,
      home: LoginWrapper(),
    );
  }
}
