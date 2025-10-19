import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_services.dart';
import '../services/geo_fence_services.dart';
import '../services/notification_service.dart';
import '../services/offline_local_storage.dart';
import '../services/permission_service.dart';
import '../services/superbase_services.dart';
import '../constants/app_colors.dart';

class ClockOutController {
  final AuthService _authService = Get.find<AuthService>();
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  final GeoFenceService _geofenceService = Get.find<GeoFenceService>();
  final OfflineLocalStorageService _offlineService = Get.find<OfflineLocalStorageService>();

  /// Handle clock-out with geofence validation
  Future<void> clockOut({
    required RxBool isClockingOut,
    required RxString clockInText,
    required RxString clockOutText,
    required RxBool isClockedIn,
    required RxString message,
    required Rx<Color> messageColor,
  }) async {
    if (isClockingOut.value) return;
    isClockingOut.value = true;
    clockOutText.value = "Clocking Out".tr;

    final user = _authService.currentUser.value;
    if (user == null) {
      isClockingOut.value = false;
      clockOutText.value = "Clock Out".tr;
      message.value = 'no_user_logged_in'.tr;
      messageColor.value = Colors.red;
      await NotificationService.showNotification(
        title: 'Clock-Out Failed',
        body: 'No user logged in.',
      );
      return;
    }

    try {
      // Validate location using GeoFenceService
      final locationResult = await _geofenceService.validateLocationForClockAction(empCode: user.empCode);
      if (!locationResult['success']) {
        isClockingOut.value = false;
        clockOutText.value = "Clock Out".tr;
        message.value = locationResult['message'];
        messageColor.value = Colors.red;
        await NotificationService.showNotification(
          title: 'Clock-Out Failed',
          body: locationResult['message'],
        );
        return;
      }

      final userLat = locationResult['latitude'] as double;
      final userLon = locationResult['longitude'] as double;
      final userId = (await _supabaseService.getUserByEmpCode(user.empCode))?['id']?.toString();

      if (userId == null) {
        isClockingOut.value = false;
        clockOutText.value = "Clock Out".tr;
        message.value = 'user_data_not_found'.tr;
        messageColor.value = Colors.red;
        await NotificationService.showNotification(
          title: 'Clock-Out Failed',
          body: 'User data not found.',
        );
        return;
      }

      final activeLog = await _supabaseService.getActiveLog(userId);
      if (activeLog == null) {
        isClockingOut.value = false;
        clockOutText.value = "Clock Out".tr;
        message.value = 'please_clock_in_first'.tr;
        messageColor.value = Colors.blue;
        await NotificationService.showNotification(
          title: 'Clock-Out Failed',
          body: 'Please clock in first.',
        );
        return;
      }

      final hasNetwork = await PermissionService.checkNetwork();
      if (!hasNetwork) {
        await _offlineService.clockOutOffline(
          empCode: user.empCode,
          lat: userLat,
          lon: userLon,
        );
        isClockingOut.value = false;
        clockOutText.value = "Clocked Out (Offline)".tr;
        isClockedIn.value = false;
        message.value = 'clock_out_saved_offline'.tr;
        messageColor.value = Colors.blue;
        await NotificationService.showNotification(
          title: 'Clock-Out Saved Offline',
          body: 'Clock-out recorded offline. Will sync later.',
        );
        return;
      }

      await _supabaseService.clockOut(activeLog.id.toString(), userLat, userLon, 'present');
      isClockingOut.value = false;
      clockOutText.value = "Clocked Out".tr;
      clockInText.value = "Clock In".tr;
      isClockedIn.value = false;
      message.value = '${'clocked_out_successfully'.tr} ${user.name}';
      messageColor.value = Colors.green;
      await NotificationService.showNotification(
        title: 'Clock-Out Successful',
        body: 'You have clocked out successfully, ${user.name}.',
      );

      // Store locally as well to ensure consistency
      await _offlineService.clockOutOffline(
        empCode: user.empCode,
        lat: userLat,
        lon: userLon,
      );
    } catch (e) {
      isClockingOut.value = false;
      clockOutText.value = "Clock Out".tr;
      message.value = '${'error_clocking_out'.tr}: $e';
      messageColor.value = Colors.red;
      await NotificationService.showNotification(
        title: 'Clock-Out Error',
        body: 'Error clocking out: $e',
      );
    }
  }
}