
import 'package:attendance_app/services/superbase_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_services.dart';
import '../services/geo_fence_services.dart';
import '../services/offline_local_storage.dart';
import '../services/permission_service.dart';
import '../services/language_controller.dart';
import '../constants/app_colors.dart';

class AdminHomeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  final GeoFenceService _geofenceService = Get.find<GeoFenceService>();
  final OfflineLocalStorageService _offlineService =
      Get.find<OfflineLocalStorageService>();
  final LanguageController _languageController =
      Get.find<LanguageController>();

  final RxBool isLoading = true.obs;
  final RxString message = ''.obs;
  final Rx<Color> messageColor = kredColor.obs;
  final RxString empCode = ''.obs;
  final RxString name = ''.obs;
  final RxString role = ''.obs;
  final RxString department = ''.obs;
  final RxList<OfflineAttendanceRecord> unsyncedRecords =
      <OfflineAttendanceRecord>[].obs;

  // Button state management
  final RxBool isClockingIn = false.obs;
  final RxBool isClockingOut = false.obs;
  final RxBool isClockedIn = false.obs;

  final RxString clockInText = "Clock In".obs;
  final RxString clockOutText = "Clock Out".obs;

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
    _initializeClockStatus();
  }

  Future<void> _initializeClockStatus() async {
    try {
      final user = _authService.currentUser.value;
      if (user == null) return;

      final userData = await _supabaseService.getUserByEmpCode(user.empCode);
      if (userData == null) return;

      final userId = userData['id'].toString();
      final activeLog = await _supabaseService.getActiveLog(userId);

      if (activeLog != null) {
        isClockedIn.value = true;
        clockInText.value = "Clocked In".tr;
        clockOutText.value = "Clock Out".tr;
      } else {
        isClockedIn.value = false;
        clockInText.value = "Clock In".tr;
        clockOutText.value = "Clocked Out".tr;
      }
    } catch (e) {
      print('Error initializing clock status: $e');
    }
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
        final departmentName =
            await _supabaseService.getDepartmentNameById(userData['department_id']);
        print('Department: $departmentName');

        empCode.value =
            '${'employee_code'.tr}: ${userData['emp_code'] ?? 'N/A'}';
        name.value = '${'name'.tr}: ${userData['name'] ?? 'N/A'}';
        role.value = '${'role'.tr}: ${userData['role'] ?? 'N/A'}';
        department.value =
            '${'department'.tr}: ${departmentName ?? 'N/A'}';
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

  // ----------------------------------------------------------
  // CLOCK IN
  // ----------------------------------------------------------
  Future<void> clockIn() async {
    if (isClockingIn.value) return;
    isClockingIn.value = true;
    clockInText.value = "Clocking In...";

    final user = _authService.currentUser.value;
    if (user == null) {
      isClockingIn.value = false;
      clockInText.value = "Clock In";
      return;
    }

    try {
      final hasNetwork = await PermissionService.checkNetwork();
      final userData = await _supabaseService.getUserByEmpCode(user.empCode);
      if (userData == null) throw Exception("User data not found.");

      final userLat = userData['lat'] ?? 0.0;
      final userLon = userData['lon'] ?? 0.0;
      final userId = userData['id'].toString();
      final activeLog = await _supabaseService.getActiveLog(userId);

      if (activeLog != null) {
        clockInText.value = "Clocked In";
        isClockedIn.value = true;
        isClockingIn.value = false;
        return;
      }

      if (!hasNetwork) {
        await _offlineService.clockInOffline(
          empCode: user.empCode,
          lat: userLat,
          lon: userLon,
        );
        clockInText.value = "Clocked In (Offline)";
        isClockedIn.value = true;
        isClockingIn.value = false;
        return;
      }

      final geofences = await _supabaseService.getGeofences();
      final isInside =
          _geofenceService.isInsideGeofence(userLat, userLon, geofences);
      if (!isInside) throw Exception("Outside allowed area");

      await _supabaseService.clockIn(userId, userLat, userLon, 'present');

      clockInText.value = "Clocked In";
      clockOutText.value = "Clock Out";
      isClockedIn.value = true;
    } catch (e) {
      clockInText.value = "Clock In";
      print('Clock-in error: $e');
    } finally {
      isClockingIn.value = false;
    }
  }

  // ----------------------------------------------------------
  // CLOCK OUT
  // ----------------------------------------------------------
  Future<void> clockOut() async {
    if (isClockingOut.value) return;
    isClockingOut.value = true;
    clockOutText.value = "Clocking Out...";

    final user = _authService.currentUser.value;
    if (user == null) {
      isClockingOut.value = false;
      clockOutText.value = "Clock Out";
      return;
    }

    try {
      final hasNetwork = await PermissionService.checkNetwork();
      final userData = await _supabaseService.getUserByEmpCode(user.empCode);
      if (userData == null) throw Exception("User data not found.");

      final userLat = userData['lat'] ?? 0.0;
      final userLon = userData['lon'] ?? 0.0;
      final userId = userData['id'].toString();
      final activeLog = await _supabaseService.getActiveLog(userId);

      if (activeLog == null) {
        clockOutText.value = "Clock Out";
        isClockingOut.value = false;
        return;
      }

      if (!hasNetwork) {
        await _offlineService.clockOutOffline(
          empCode: user.empCode,
          lat: userLat,
          lon: userLon,
        );
        clockOutText.value = "Clocked Out (Offline)";
        isClockedIn.value = false;
        isClockingOut.value = false;
        return;
      }

      final geofences = await _supabaseService.getGeofences();
      final isInside =
          _geofenceService.isInsideGeofence(userLat, userLon, geofences);
      if (!isInside) throw Exception("Outside allowed area");

      await _supabaseService.clockOut(
        activeLog.id.toString(),
        userLat,
        userLon,
        'present',
      );

      clockOutText.value = "Clocked Out";
      clockInText.value = "Clock In";
      isClockedIn.value = false;
    } catch (e) {
      clockOutText.value = "Clock Out";
      print('Clock-out error: $e');
    } finally {
      isClockingOut.value = false;
    }
  }
}
