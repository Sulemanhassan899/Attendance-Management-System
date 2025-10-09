

import 'package:attendance_app/services/superbase_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_services.dart';
import '../services/geo_fence_services.dart';
import '../services/notification_service.dart';
import '../services/offline_local_storage.dart';
import '../services/permission_service.dart';
import '../services/language_controller.dart';
import '../constants/app_colors.dart';

class HomeController extends GetxController {
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
  final RxString supervisor = ''.obs;
  final RxList<OfflineAttendanceRecord> unsyncedRecords = <OfflineAttendanceRecord>[].obs;

  // Button state observables
  final RxBool isClockedIn = false.obs;
  final RxString clockInButtonText = "Clock In".obs;
  final RxString clockOutButtonText = "Clock Out".obs;

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
    final hasNetwork = await PermissionService.checkNetwork();
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
        await checkClockInStatus();
      } else {
        empCode.value = 'offline_mode'.tr;
      }
      await _offlineService.syncRecords();
      await fetchUnsyncedRecords();
    } catch (_) {
      message.value = 'error_initializing'.tr;
      messageColor.value = Colors.red;
    }
    isLoading.value = false;
  }

  Future<void> fetchUserInfo() async {
    try {
      final user = _authService.currentUser.value;
      if (user == null) {
        empCode.value = 'no_user_info'.tr;
        name.value = '';
        role.value = '';
        department.value = '';
        supervisor.value = '';
        return;
      }

      final userData = await _supabaseService.getUserByEmpCode(user.empCode);

      if (userData != null && userData.isNotEmpty) {
        final supervisorName = await _supabaseService.getSupervisorNameByEmpCode(user.empCode);
        final departmentName = await _supabaseService.getDepartmentNameById(userData['department_id']);

        empCode.value = '${'employee_code'.tr}: ${userData['emp_code'] ?? 'N/A'}';
        name.value = '${'name'.tr}: ${userData['name'] ?? 'N/A'}';
        role.value = '${'role'.tr}: ${userData['role'] ?? 'N/A'}';
        department.value = '${'department'.tr}: ${departmentName ?? 'N/A'}';
        supervisor.value = '${'supervisor'.tr}: ${supervisorName ?? 'not_assigned'.tr}';
      } else {
        empCode.value = 'failed_fetch_user'.tr;
      }
    } catch (_) {
      empCode.value = 'error_fetching_user'.tr;
    }
    update();
  }

  Future<void> fetchUnsyncedRecords() async {
    try {
      final records = await _offlineService.getUnsyncedRecords();
      unsyncedRecords.assignAll(records);
    } catch (_) {}
  }

  Future<void> checkClockInStatus() async {
    final user = _authService.currentUser.value;
    if (user == null) return;

    try {
      final userData = await _supabaseService.getUserByEmpCode(user.empCode);
      if (userData == null) return;

      final userId = userData['id'].toString();
      final activeLog = await _supabaseService.getActiveLog(userId);
      isClockedIn.value = activeLog != null;

      // Update button text based on current state
      clockInButtonText.value = isClockedIn.value ? "Clocked In" : "Clock In";
      clockOutButtonText.value = isClockedIn.value ? "Clock Out" : "Clocked Out";
    } catch (_) {}
  }

  Future<void> clockIn() async {
    final user = _authService.currentUser.value;
    if (user == null) return;

    clockInButtonText.value = "Clocking In...";

    try {
      final hasNetwork = await PermissionService.checkNetwork();
      if (!hasNetwork) {
        await _offlineService.clockInOffline(
          empCode: user.empCode,
          lat: user.lat ?? 0.0,
          lon: user.lon ?? 0.0,
        );
        message.value = 'clock_in_saved_offline'.tr;
        messageColor.value = Colors.blue;
        await NotificationService.showNotification(
          title: 'Clock-In Saved Offline',
          body: 'Clock-in recorded offline. Will sync later.',
        );
        clockInButtonText.value = "Clocked In";
        isClockedIn.value = true;
        return;
      }

      final userData = await _supabaseService.getUserByEmpCode(user.empCode);
      if (userData == null) return;

      final userLat = userData['lat'] as double;
      final userLon = userData['lon'] as double;
      final userId = userData['id'].toString();

      final activeLog = await _supabaseService.getActiveLog(userId);
      if (activeLog != null) {
        message.value = 'already_clocked_in'.tr;
        messageColor.value = Colors.blue;
        clockInButtonText.value = "Clocked In";
        return;
      }

      final geofences = await _supabaseService.getGeofences();
      final isInside = _geofenceService.isInsideGeofence(userLat, userLon, geofences);

      if (isInside) {
        await _supabaseService.clockIn(userId, userLat, userLon, 'present');
        message.value = '${'clocked_in_successfully'.tr} ${user.name}';
        messageColor.value = Colors.green;
        await NotificationService.showNotification(
          title: 'Clock-In Successful',
          body: 'You have clocked in successfully.',
        );
        clockInButtonText.value = "Clocked In";
        isClockedIn.value = true;
      } else {
        clockInButtonText.value = "Clock In";
        message.value = _geofenceService.geofenceMessage.value;
        messageColor.value = Colors.red;
      }
    } catch (_) {
      clockInButtonText.value = "Clock In";
      message.value = 'error_clocking_in'.tr;
      messageColor.value = Colors.red;
    }
  }

  Future<void> clockOut() async {
    final user = _authService.currentUser.value;
    if (user == null) return;

    clockOutButtonText.value = "Clocking Out...";

    try {
      final hasNetwork = await PermissionService.checkNetwork();
      if (!hasNetwork) {
        await _offlineService.clockOutOffline(
          empCode: user.empCode,
          lat: user.lat ?? 0.0,
          lon: user.lon ?? 0.0,
        );
        message.value = 'clock_out_saved_offline'.tr;
        messageColor.value = Colors.blue;
        await NotificationService.showNotification(
          title: 'Clock-Out Saved Offline',
          body: 'Clock-out recorded offline. Will sync later.',
        );
        clockOutButtonText.value = "Clocked Out";
        isClockedIn.value = false;
        return;
      }

      final userData = await _supabaseService.getUserByEmpCode(user.empCode);
      if (userData == null) return;

      final userLat = userData['lat'] as double;
      final userLon = userData['lon'] as double;
      final userId = userData['id'].toString();

      final activeLog = await _supabaseService.getActiveLog(userId);
      if (activeLog == null) {
        message.value = 'please_clock_in_first'.tr;
        messageColor.value = Colors.blue;
        clockOutButtonText.value = "Clock Out";
        return;
      }

      final geofences = await _supabaseService.getGeofences();
      final isInside = _geofenceService.isInsideGeofence(userLat, userLon, geofences);

      if (isInside) {
        await _supabaseService.clockOut(activeLog.id.toString(), userLat, userLon, 'present');
        message.value = '${'clocked_out_successfully'.tr} ${user.name}';
        messageColor.value = Colors.green;
        await NotificationService.showNotification(
          title: 'Clock-Out Successful',
          body: 'You have clocked out successfully.',
        );
        clockOutButtonText.value = "Clocked Out";
        isClockedIn.value = false;
      } else {
        clockOutButtonText.value = "Clock Out";
        message.value = _geofenceService.geofenceMessage.value;
        messageColor.value = Colors.red;
      }
    } catch (_) {
      clockOutButtonText.value = "Clock Out";
      message.value = 'error_clocking_out'.tr;
      messageColor.value = Colors.red;
    }
  }
}
