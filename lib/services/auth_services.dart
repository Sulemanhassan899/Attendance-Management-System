

// File: services/auth_services.dart
import 'package:attendance_app/models/user_models.dart' as app_models;
import 'package:attendance_app/services/permission_service.dart';
import 'package:attendance_app/view/screens/admin/home_admin.dart';
import 'package:attendance_app/view/screens/employee/home.dart';
import 'package:attendance_app/view/screens/supervisor/home_supervisor.dart';
import 'package:get/Get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:local_auth/local_auth.dart';

class AuthService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final LocalAuthentication _localAuth = LocalAuthentication();

  final Rx<app_models.User?> currentUser = Rx<app_models.User?>(null);

  @override
  void onInit() {
    super.onInit();
    print('AuthService initialized');
    // Verify Supabase client configuration
    if (_supabase.rest.url.isEmpty) {
      print('Supabase URL is empty. Check initialization.');
    } else {
      print('Supabase URL: ${_supabase.rest.url}');
    }
    // Log anon key safely (first 10 characters for security)
    final anonKey = Supabase.instance.client.auth.currentSession?.accessToken;
    print('Supabase anon key: ${anonKey != null ? anonKey.substring(0, anonKey.length > 10 ? 10 : anonKey.length) : 'null'}...');
  }

  Future<bool> login(String empCode, String password) async {
  print('=== LOGIN DEBUG START ===');
  print('Attempting login with empCode: "$empCode" and password: "$password"');

  final hasNetwork = await PermissionService.checkNetwork();
  if (!hasNetwork) {
    print('No network connection. Cannot login online.');
    return false;
  }

  try {
    print('Testing database connection...');
    final testResponse = await _supabase
        .from('users')
        .select('emp_code')
        .limit(1);
    print('Database connection successful. Sample data: $testResponse');

    print('Checking if user exists with emp_code: "$empCode"');
    final userExistsResponse = await _supabase
        .from('users')
        .select('emp_code, name, role')
        .eq('emp_code', empCode);

    print('Users found with emp_code "$empCode": ${userExistsResponse.length}');
    if (userExistsResponse.isNotEmpty) {
      print('User data: ${userExistsResponse.first}');
    } else {
      print('No user found with emp_code: "$empCode"');
      return false;
    }

    print('Checking password match...');
    final response = await _supabase
        .from('users')
        .select('*')
        .eq('emp_code', empCode)
        .eq('password', password)
        .maybeSingle();

    print('Password check result: $response');

    if (response != null) {
      print('Login successful! User data: $response');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('emp_code', empCode);
      await prefs.setString('password', password);

      // Set currentUser
      currentUser.value = app_models.User.fromJson(response);

      // Check role
      final role = response['role'];
      if (role == 'employee') {
        // Navigate to the employee home screen
        Get.off(() => HomeScreen());
      } else if (role == 'supervisor') {
        // Navigate to the supervisor home screen
        Get.off(() => SupervisorHomeScreen());
      } else if (role == 'admin') {
        // Navigate to the admin home screen
        Get.off(() => AdminHomeScreen());
      } else {
        print('Unknown role');
        return false;
      }
      return true;
    } else {
      print('No user found with matching credentials');
      return false;
    }
  } catch (e, stackTrace) {
    print('Login error: $e');
    print('Stack trace: $stackTrace');
    return false;
  } finally {
    print('=== LOGIN DEBUG END ===');
  }
}


  Future<bool> login1(String empCode, String password) async {
    print('=== LOGIN DEBUG START ===');
    print('Attempting login with empCode: "$empCode" and password: "$password"');

    // Check network connectivity before attempting login
    final hasNetwork = await PermissionService.checkNetwork();
    if (!hasNetwork) {
      print('No network connection. Cannot login online.');
      return false; // Offline login not supported in this version
    }

    try {
      print('Testing database connection...');
      final testResponse = await _supabase
          .from('users')
          .select('emp_code')
          .limit(1);
      print('Database connection successful. Sample data: $testResponse');

      print('Checking if user exists with emp_code: "$empCode"');
      final userExistsResponse = await _supabase
          .from('users')
          .select('emp_code, name, role')
          .eq('emp_code', empCode);

      print('Users found with emp_code "$empCode": ${userExistsResponse.length}');
      if (userExistsResponse.isNotEmpty) {
        print('User data: ${userExistsResponse.first}');
      } else {
        print('No user found with emp_code: "$empCode"');
        return false;
      }

      print('Checking password match...');
      final response = await _supabase
          .from('users')
          .select('*')
          .eq('emp_code', empCode)
          .eq('password', password)
          .maybeSingle();

      print('Password check result: $response');

      if (response != null) {
        print('Login successful! User data: $response');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('emp_code', empCode);
        await prefs.setString('password', password);

        currentUser.value = app_models.User.fromJson(response);
        return true;
      } else {
        print('No user found with matching credentials');
        return false;
      }
    } catch (e, stackTrace) {
      print('Login error: $e');
      print('Stack trace: $stackTrace');
      if (e.toString().contains('SocketException')) {
        print('Network error during login. Check connectivity or Supabase URL.');
      }
      return false;
    } finally {
      print('=== LOGIN DEBUG END ===');
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final empCode = prefs.getString('emp_code');
      final password = prefs.getString('password');

      if (empCode != null && password != null) {
        return await login(empCode, password);
      }
      print('No stored credentials found');
      return false;
    } catch (e) {
      print('isLoggedIn error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      currentUser.value = null;
      print('Logout successful');
    } catch (e) {
      print('Logout error: $e');
    }
  }

  Future<app_models.User?> getCurrentUser() async {
    try {
      if (currentUser.value != null) return currentUser.value;

      final prefs = await SharedPreferences.getInstance();
      final empCode = prefs.getString('emp_code');

      if (empCode != null) {
        // Check network before fetching user
        final hasNetwork = await PermissionService.checkNetwork();
        if (!hasNetwork) {
          print('No network. Cannot fetch current user.');
          return null;
        }

        final response = await _supabase
            .from('users')
            .select()
            .eq('emp_code', empCode)
            .maybeSingle();

        if (response != null) {
          currentUser.value = app_models.User.fromJson(response);
          print('Current user fetched: ${currentUser.value?.empCode}');
          return currentUser.value;
        }
      }
      print('No current user found');
      return null;
    } catch (e) {
      print('getCurrentUser error: $e');
      if (e.toString().contains('SocketException')) {
        print('Network error during getCurrentUser');
      }
      return null;
    }
  }

  Future<void> debugAllUsers() async {
    try {
      print('=== ALL USERS DEBUG ===');
      final response = await _supabase
          .from('users')
          .select('emp_code, name, role, password');

      print('Total users in database: ${response.length}');
      for (var user in response) {
        print(
          'User: ${user['emp_code']} | Name: ${user['name']} | Password: ${user['password']}',
        );
      }
      print('=== ALL USERS DEBUG END ===');
    } catch (e) {
      print('Error fetching all users: $e');
      if (e.toString().contains('SocketException')) {
        print('Network error during debugAllUsers');
      }
    }
  }
}