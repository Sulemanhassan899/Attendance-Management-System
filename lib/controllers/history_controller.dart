import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/attendance_log_models.dart';
import '../services/auth_services.dart';
import '../services/superbase_services.dart';

class HistoryController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  var logs = <AttendanceLog>[].obs;
  var isLoading = true.obs;

  var selectedRecent = RxnString();
  var selectedMonth = RxnString();
  var selectedDate = RxnString();

  var monthOptions = <String>[].obs;
  var dateOptions = <String>[].obs;

  final recentOptions = ['Recent', 'Old', 'All Time'];

  @override
  void onInit() {
    super.onInit();
    generateMonthOptions();
    fetchHistory();
  }

  void generateMonthOptions() {
    final now = DateTime.now();
    final dateFormat = DateFormat('MMMM yyyy');
    monthOptions.clear();
    for (int i = 0; i < 12; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      monthOptions.add(dateFormat.format(date));
    }
  }

  void generateDateOptions(String? month) {
    dateOptions.clear();
    if (month == null || month.isEmpty) return;

    final monthFormat = DateFormat('MMMM yyyy');
    final selected = monthFormat.parse(month);
    final daysInMonth = DateTime(selected.year, selected.month + 1, 0).day;

    final dateFormat = DateFormat('dd-MM-yyyy');

    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(selected.year, selected.month, i);
      dateOptions.add(dateFormat.format(date));
    }
  }

  Future<void> fetchHistory() async {
    isLoading.value = true;

    final user = await _authService.getCurrentUser();
    if (user == null) {
      logs.clear();
      isLoading.value = false;
      return;
    }

    List<AttendanceLog> fetchedLogs = [];
    bool ascending = selectedRecent.value == 'Old';

    if (selectedDate.value != null && selectedDate.value!.isNotEmpty) {
      final dateFormat = DateFormat('dd-MM-yyyy');
      final parsedDate = dateFormat.parse(selectedDate.value!);
      fetchedLogs = await _supabaseService.getDailyAttendanceHistory(
        user.id,
        parsedDate,
      );
    } else if (selectedMonth.value != null && selectedMonth.value!.isNotEmpty) {
      final dateFormat = DateFormat('MMMM yyyy');
      final parsedMonth = dateFormat.parse(selectedMonth.value!);
      fetchedLogs = await _supabaseService.getMonthlyAttendanceHistory(
        user.id,
        parsedMonth.year,
        parsedMonth.month,
      );
    } else if (selectedRecent.value == 'All Time') {
      fetchedLogs = await _supabaseService.getFilteredAttendanceHistory(
        user.id,
        'All Time',
      );
    } else {
      fetchedLogs = await _supabaseService.getDailyAttendanceHistory(
        user.id,
        DateTime.now(),
      );
    }

    fetchedLogs.sort((a, b) => ascending
        ? a.clockInTime!.compareTo(b.clockInTime!)
        : b.clockInTime!.compareTo(a.clockInTime!));

    logs.assignAll(fetchedLogs);
    isLoading.value = false;
  }

  void onRecentChanged(dynamic value) {
    selectedRecent.value = value as String?;
    fetchHistory();
  }

  void onMonthChanged(dynamic value) {
    selectedMonth.value = value as String?;
    selectedDate.value = null;
    generateDateOptions(selectedMonth.value);
    fetchHistory();
  }

  void onDateChanged(dynamic value) {
    selectedDate.value = value as String?;
    fetchHistory();
  }
}
