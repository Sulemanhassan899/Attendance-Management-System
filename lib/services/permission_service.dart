

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> checkNetwork() async {
    try {
      print('Checking network connectivity at ${DateTime.now()} PKT...');
      
      // Step 1: Check basic connectivity
      var connectivityResult = await Connectivity().checkConnectivity();
      print('Connectivity result: $connectivityResult');
      if (connectivityResult == ConnectivityResult.none) {
        print('No network interface detected');
        return false;
      }

      // Step 2: Perform a test request to a reliable endpoint
      const testUrl = 'https://www.google.com'; // Fallback reliable URL
      try {
        final response = await http
            .get(Uri.parse(testUrl))
            .timeout(const Duration(seconds: 10)); // Increased timeout to 10 seconds
        final isConnected = response.statusCode == 200;
        print('Network test to $testUrl: Status ${response.statusCode} - $isConnected');
        return isConnected;
      } catch (e) {
        print('HTTP test to $testUrl failed: $e');
      }

      // Step 3: Test Supabase connectivity as a specific check
      const supabaseTestUrl = 'https://cpvyypvivqwjyxtmqeli.supabase.co/health'; // Supabase health check
      try {
        final supabaseResponse = await http
            .get(Uri.parse(supabaseTestUrl))
            .timeout(const Duration(seconds: 10));
        final isSupabaseConnected = supabaseResponse.statusCode == 200;
        print('Supabase test to $supabaseTestUrl: Status ${supabaseResponse.statusCode} - $isSupabaseConnected');
        return isSupabaseConnected;
      } catch (e) {
        print('Supabase connectivity test failed: $e');
      }

      print('No reliable internet connection detected');
      return false;
    } catch (e) {
      print('Critical network check error: $e');
      return false;
    }
  }

  static Future<bool> checkLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permission denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permission permanently denied');
        return false;
      }

      print('Location permission granted at ${DateTime.now()} PKT');
      return true;
    } catch (e) {
      print('Error checking location permission: $e');
      return false;
    }
  }

  // NEW: Notification permission check and request
  static Future<bool> checkNotificationPermission() async {
    try {
      // Check current permission status
      PermissionStatus status = await Permission.notification.status;
      
      if (status.isGranted) {
        print('Notification permission already granted at ${DateTime.now()} PKT');
        return true;
      }

      if (status.isDenied) {
        // Request permission
        print('Requesting notification permission...');
        PermissionStatus result = await Permission.notification.request();
        
        if (result.isGranted) {
          print('Notification permission granted at ${DateTime.now()} PKT');
          return true;
        } else if (result.isDenied) {
          print('Notification permission denied');
          return false;
        } else if (result.isPermanentlyDenied) {
          print('Notification permission permanently denied');
          // Optionally open app settings
          // await openAppSettings();
          return false;
        }
      }

      if (status.isPermanentlyDenied) {
        print('Notification permission permanently denied - please enable in settings');
        return false;
      }

      return false;
    } catch (e) {
      print('Error checking notification permission: $e');
      return false;
    }
  }

  // NEW: Check all permissions at once
  static Future<Map<String, bool>> checkAllPermissions() async {
    try {
      final location = await checkLocationPermission();
      final notification = await checkNotificationPermission();
      final network = await checkNetwork();

      return {
        'location': location,
        'notification': notification,
        'network': network,
      };
    } catch (e) {
      print('Error checking all permissions: $e');
      return {
        'location': false,
        'notification': false,
        'network': false,
      };
    }
  }

  // NEW: Open app settings if permission is permanently denied
  static Future<void> openSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      print('Error opening app settings: $e');
    }
  }
}
