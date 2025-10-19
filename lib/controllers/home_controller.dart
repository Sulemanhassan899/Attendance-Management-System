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
import 'clock_in_controller.dart';
import 'clock_out_controller.dart';

class HomeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  final GeoFenceService _geofenceService = Get.find<GeoFenceService>();
  final OfflineLocalStorageService _offlineService = Get.find<OfflineLocalStorageService>();
  final LanguageController _languageController = Get.find<LanguageController>();
  final ClockInController _clockInController = ClockInController();
  final ClockOutController _clockOutController = ClockOutController();

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
    await _clockInController.checkClockStatus(
      isClockedIn: isClockedIn,
      clockInText: clockInButtonText,
      clockOutText: clockOutButtonText,
    );
  }

  Future<void> clockIn() async {
    await _clockInController.clockIn(
      isClockingIn: RxBool(false),
      clockInText: clockInButtonText,
      clockOutText: clockOutButtonText,
      isClockedIn: isClockedIn,
      message: message,
      messageColor: messageColor,
    );
  }

  Future<void> clockOut() async {
    await _clockOutController.clockOut(
      isClockingOut: RxBool(false),
      clockInText: clockInButtonText,
      clockOutText: clockOutButtonText,
      isClockedIn: isClockedIn,
      message: message,
      messageColor: messageColor,
    );
  }
}