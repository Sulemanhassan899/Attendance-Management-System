// File: controllers/admin_home_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_services.dart';
import '../services/geo_fence_services.dart';
import '../services/superbase_services.dart';
import '../services/offline_local_storage.dart';
import '../services/permission_service.dart';
import '../services/language_controller.dart';
import '../constants/app_colors.dart';

class AdminHomeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  final GeoFenceService _geofenceService = Get.find<GeoFenceService>();
  final OfflineLocalStorageService _offlineService = Get.find<OfflineLocalStorageService>();
  final LanguageController _languageController = Get.find<LanguageController>();

  final RxBool isLoading = true.obs;
  final RxString message = ''.obs;
  final Rx<Color> messageColor = kredColor.obs;
  final RxString empCode = ''.obs;
  final RxString name = ''.obs;
  final RxString role = ''.obs;
  final RxString department = ''.obs;
  final RxList<OfflineAttendanceRecord> unsyncedRecords = <OfflineAttendanceRecord>[].obs;

  AuthService get authService => _authService;
  SupabaseService get supabaseService => _supabaseService;
  GeoFenceService get geofenceService => _geofenceService;
  OfflineLocalStorageService get offlineService => _offlineService;
  LanguageController get languageController => _languageController;

  @override
  void onInit() {
    super.onInit();
    ever(_languageController.isUrdu, (_) => fetchUserInfo());
    init();
  }

  Future<void> init() async {
    print('Initializing AdminHomeScreen...');
    final hasNetwork = await PermissionService.checkNetwork();
    print('Network status during init: $hasNetwork');
    if (!hasNetwork) {
      message.value = 'no_internet'.tr;
      messageColor.value = Colors.red;
    }
    final hasLocation = await PermissionService.checkLocationPermission();
    if (!hasLocation) {
      message.value = 'location_permission_required'.tr;
      messageColor.value = Colors.red;
      return;
    }
    isLoading.value = true;
    try {
      if (hasNetwork) {
        final geofences = await _supabaseService.getGeofences();
        await _geofenceService.setupGeofences(geofences);
        await fetchUserInfo();
      } else {
        print('Skipping online initialization due to no network');
        empCode.value = 'offline_mode'.tr;
      }
      await _offlineService.syncRecords();
      await fetchUnsyncedRecords();
    } catch (e) {
      print('Init error: $e');
      message.value = '${'error_initializing'.tr}: $e';
      messageColor.value = Colors.red;
    }
    isLoading.value = false;
    print('AdminHomeScreen initialization complete');
  }

  Future<void> fetchUserInfo() async {
    try {
      final user = _authService.currentUser.value;
      if (user == null) {
        print('No user found in authService');
        empCode.value = 'no_user_info'.tr;
        name.value = '';
        role.value = '';
        department.value = '';
        return;
      }
      print('Fetching user info for empCode: ${user.empCode}');
      final userData = await _supabaseService.getUserByEmpCode(user.empCode);
      print('User data fetched: $userData');

      if (userData != null && userData.isNotEmpty) {
        final departmentName = await _supabaseService.getDepartmentNameById(userData['department_id']);
        print('Department: $departmentName');
        
        empCode.value = '${'employee_code'.tr}: ${userData['emp_code'] ?? 'N/A'}';
        name.value = '${'name'.tr}: ${userData['name'] ?? 'N/A'}';
        role.value = '${'role'.tr}: ${userData['role'] ?? 'N/A'}';
        department.value = '${'department'.tr}: ${departmentName ?? 'N/A'}';
      } else {
        print('No user data returned from Supabase');
        empCode.value = 'failed_fetch_user'.tr;
        name.value = '';
        role.value = '';
        department.value = '';
      }
    } catch (e) {
      print('Error fetching user info: $e');
      empCode.value = '${'error_fetching_user'.tr}: $e';
      name.value = '';
      role.value = '';
      department.value = '';
    }
    update();
  }

  Future<void> fetchUnsyncedRecords() async {
    try {
      final records = await _offlineService.getUnsyncedRecords();
      print('Unsynced records fetched: ${records.length}');
      unsyncedRecords.assignAll(records);
    } catch (e) {
      print('Error fetching unsynced records: $e');
    }
  }

  Future<void> clockIn() async {
    final user = _authService.currentUser.value;
    if (user == null) {
      print('Current user: ${_authService.currentUser.value}');
      message.value = 'no_user_logged_in'.tr;
      messageColor.value = Colors.red;
      return;
    }
    try {
      final hasNetwork = await PermissionService.checkNetwork();
      print('Network status for clock-in: $hasNetwork');
      if (!hasNetwork) {
        print('No network, saving clock-in offline');
        await _offlineService.clockInOffline(
          empCode: user.empCode,
          lat: user.lat ?? 0.0,
          lon: user.lon ?? 0.0,
        );
        message.value = 'clock_in_saved_offline'.tr;
        messageColor.value = Colors.blue;
        return;
      }
      final userData = await _supabaseService.getUserByEmpCode(user.empCode);
      print('User data for clock-in: $userData');
      if (userData == null) {
        message.value = 'user_data_not_found'.tr;
        messageColor.value = Colors.red;
        return;
      }
      if (userData['lat'] == null || userData['lon'] == null) {
        message.value = 'user_location_not_found'.tr;
        messageColor.value = Colors.red;
        return;
      }
      final userLat = userData['lat'] as double;
      final userLon = userData['lon'] as double;
      final userId = userData['id'].toString();
      final activeLog = await _supabaseService.getActiveLog(userId);
      print('Active log check: $activeLog');
      if (activeLog != null) {
        message.value = 'already_clocked_in'.tr;
        messageColor.value = Colors.blue;
        return;
      }
      final geofences = await _supabaseService.getGeofences();
      print('Geofences for clock-in: $geofences');
      final isInside = _geofenceService.isInsideGeofence(
        userLat,
        userLon,
        geofences,
      );
      if (isInside) {
        await _supabaseService.clockIn(userId, userLat, userLon, 'present');
        message.value = 'clocked_in_successfully'.tr;
        messageColor.value = Colors.green;
      } else {
        message.value = _geofenceService.geofenceMessage.value;
        messageColor.value = Colors.red;
      }
    } catch (e) {
      print('Clock-in error: $e');
      if (e.toString().contains('SocketException')) {
        print('Network error, saving clock-in offline');
        await _offlineService.clockInOffline(
          empCode: user.empCode,
          lat: user.lat ?? 0.0,
          lon: user.lon ?? 0.0,
        );
        message.value = 'network_error_try_offline'.tr;
        messageColor.value = Colors.blue;
      } else {
        message.value = '${'error_clocking_in'.tr}: $e';
        messageColor.value = Colors.red;
      }
    }
  }

  Future<void> clockOut() async {
    final user = _authService.currentUser.value;
    if (user == null) {
      message.value = 'no_user_logged_in'.tr;
      messageColor.value = Colors.red;
      return;
    }
    try {
      final hasNetwork = await PermissionService.checkNetwork();
      print('Network status for clock-out: $hasNetwork');
      if (!hasNetwork) {
        print('No network, saving clock-out offline');
        await _offlineService.clockOutOffline(
          empCode: user.empCode,
          lat: user.lat ?? 0.0,
          lon: user.lon ?? 0.0,
        );
        message.value = 'clock_out_saved_offline'.tr;
        messageColor.value = Colors.blue;
        return;
      }
      final userData = await _supabaseService.getUserByEmpCode(user.empCode);
      print('User data for clock-out: $userData');
      if (userData == null) {
        message.value = 'user_data_not_found'.tr;
        messageColor.value = Colors.red;
        return;
      }
      if (userData['lat'] == null || userData['lon'] == null) {
        message.value = 'user_location_not_found'.tr;
        messageColor.value = Colors.red;
        return;
      }
      final userLat = userData['lat'] as double;
      final userLon = userData['lon'] as double;
      final userId = userData['id'].toString();
      final activeLog = await _supabaseService.getActiveLog(userId);
      print('Active log for clock-out: $activeLog');
      if (activeLog == null) {
        message.value = 'please_clock_in_first'.tr;
        messageColor.value = Colors.blue;
        return;
      }
      final geofences = await _supabaseService.getGeofences();
      print('Geofences for clock-out: $geofences');
      final isInside = _geofenceService.isInsideGeofence(
        userLat,
        userLon,
        geofences,
      );
      if (isInside) {
        await _supabaseService.clockOut(
          activeLog.id.toString(),
          userLat,
          userLon,
          'present',
        );
        message.value = '${'clocked_out_successfully'.tr} ${user.name}';
        messageColor.value = Colors.green;
      } else {
        message.value = _geofenceService.geofenceMessage.value;
        messageColor.value = Colors.red;
      }
    } catch (e) {
      print('Clock-out error: $e');
      if (e.toString().contains('SocketException')) {
        print('Network error, saving clock-out offline');
        await _offlineService.clockOutOffline(
          empCode: user.empCode,
          lat: user.lat ?? 0.0,
          lon: user.lon ?? 0.0,
        );
        message.value = 'network_error_try_offline'.tr;
        messageColor.value = Colors.blue;
      } else {
        message.value = '${'error_clocking_out'.tr}: $e';
        messageColor.value = Colors.red;
      }
    }
  }
}