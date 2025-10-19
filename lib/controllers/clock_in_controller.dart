import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_services.dart';
import '../services/geo_fence_services.dart';
import '../services/notification_service.dart';
import '../services/offline_local_storage.dart';
import '../services/permission_service.dart';
import '../services/superbase_services.dart';
import '../constants/app_colors.dart';

class ClockInController {
  final AuthService _authService = Get.find<AuthService>();
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  final GeoFenceService _geofenceService = Get.find<GeoFenceService>();
  final OfflineLocalStorageService _offlineService = Get.find<OfflineLocalStorageService>();

  /// Check clock-in status and update UI accordingly
  Future<void> checkClockStatus({
    required RxBool isClockedIn,
    required RxString clockInText,
    required RxString clockOutText,
  }) async {
    try {
      final user = _authService.currentUser.value;
      if (user == null) return;
      final userData = await _supabaseService.getUserByEmpCode(user.empCode);
      if (userData == null) return;
      final userId = userData['id'].toString();
      final activeLog = await _supabaseService.getActiveLog(userId);
      isClockedIn.value = activeLog != null;
      clockInText.value = activeLog != null ? 'Clocked In'.tr : 'Clock In'.tr;
      clockOutText.value = activeLog != null ? 'Clock Out'.tr : 'Clocked Out'.tr;
    } catch (e) {
      isClockedIn.value = false;
      clockInText.value = 'Clock In'.tr;
      clockOutText.value = 'Clocked Out'.tr;
      print('Error checking clock status: $e');
    }
  }

  /// Handle clock-in with geofence validation
  Future<void> clockIn({
    required RxBool isClockingIn,
    required RxString clockInText,
    required RxString clockOutText,
    required RxBool isClockedIn,
    required RxString message,
    required Rx<Color> messageColor,
  }) async {
    if (isClockingIn.value) return;
    isClockingIn.value = true;
    clockInText.value = "Clocking In".tr;

    final user = _authService.currentUser.value;
    if (user == null) {
      isClockingIn.value = false;
      clockInText.value = "Clock In".tr;
      message.value = 'no_user_logged_in'.tr;
      messageColor.value = Colors.red;
      await NotificationService.showNotification(
        title: 'Clock-In Failed',
        body: 'No user logged in.',
      );
      return;
    }

    try {
      // Validate location using GeoFenceService
      final locationResult = await _geofenceService.validateLocationForClockAction(empCode: user.empCode);
      if (!locationResult['success']) {
        isClockingIn.value = false;
        clockInText.value = "Clock In".tr;
        message.value = locationResult['message'];
        messageColor.value = Colors.red;
        await NotificationService.showNotification(
          title: 'Clock-In Failed',
          body: locationResult['message'],
        );
        return;
      }

      final userLat = locationResult['latitude'] as double;
      final userLon = locationResult['longitude'] as double;
      final userId = (await _supabaseService.getUserByEmpCode(user.empCode))?['id']?.toString();

      if (userId == null) {
        isClockingIn.value = false;
        clockInText.value = "Clock In".tr;
        message.value = 'user_data_not_found'.tr;
        messageColor.value = Colors.red;
        await NotificationService.showNotification(
          title: 'Clock-In Failed',
          body: 'User data not found.',
        );
        return;
      }

      final activeLog = await _supabaseService.getActiveLog(userId);
      if (activeLog != null) {
        isClockingIn.value = false;
        clockInText.value = "Clocked In".tr;
        isClockedIn.value = true;
        message.value = 'already_clocked_in'.tr;
        messageColor.value = Colors.blue;
        await NotificationService.showNotification(
          title: 'Clock-In Failed',
          body: 'You are already clocked in.',
        );
        return;
      }

      final hasNetwork = await PermissionService.checkNetwork();
      if (!hasNetwork) {
        await _offlineService.clockInOffline(
          empCode: user.empCode,
          lat: userLat,
          lon: userLon,
        );
        isClockingIn.value = false;
        clockInText.value = "Clocked In (Offline)".tr;
        isClockedIn.value = true;
        message.value = 'clock_in_saved_offline'.tr;
        messageColor.value = Colors.blue;
        await NotificationService.showNotification(
          title: 'Clock-In Saved Offline',
          body: 'Clock-in recorded offline. Will sync later.',
        );
        return;
      }

      await _supabaseService.clockIn(userId, userLat, userLon, 'present');
      isClockingIn.value = false;
      clockInText.value = "Clocked In".tr;
      clockOutText.value = "Clock Out".tr;
      isClockedIn.value = true;
      message.value = '${'clocked_in_successfully'.tr} ${user.name}';
      messageColor.value = Colors.green;
      await NotificationService.showNotification(
        title: 'Clock-In Successful',
        body: 'You have clocked in successfully.',
      );

      // Store locally as well to ensure consistency
      await _offlineService.clockInOffline(
        empCode: user.empCode,
        lat: userLat,
        lon: userLon,
      );
    } catch (e) {
      isClockingIn.value = false;
      clockInText.value = "Clock In".tr;
      message.value = '${'error_clocking_in'.tr}: $e';
      messageColor.value = Colors.red;
      await NotificationService.showNotification(
        title: 'Clock-In Error',
        body: 'Error clocking in: $e',
      );
    }
  }
}