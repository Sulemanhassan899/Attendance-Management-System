

// File: services/supabase_services.dart
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attendance_log_models.dart';
import '../models/geo_fence_model.dart';
import 'package:attendance_app/services/permission_service.dart';

class SupabaseService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    print('Supabase URL: ${_supabase.rest.url}');
    final anonKey = Supabase.instance.client.auth.currentSession?.accessToken;
    print('Supabase anon key: ${anonKey != null ? anonKey.substring(0, anonKey.length > 10 ? 10 : anonKey.length) : 'null'}...');
  }

  Future<List<Geofence>> getGeofences() async {
    if (!await PermissionService.checkNetwork()) {
      print('No network. Skipping geofences fetch.');
      return [];
    }
    try {
      print('Fetching geofences...');
      final response = await _supabase.from('geofences').select();
      print('Geofences response: $response');
      return (response as List).map((json) => Geofence.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching geofences: $e');
      if (e.toString().contains('SocketException')) {
        print('Network error: Unable to connect to Supabase. URL: ${_supabase.rest.url}');
      }
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllOfficeLocations() async {
    if (!await PermissionService.checkNetwork()) {
      print('No network. Skipping office locations fetch.');
      return [];
    }
    try {
      print('Fetching office locations from geofences...');
      final response = await _supabase.from('geofences').select('id, name');
      print('Office locations response: $response');
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('Error fetching office locations: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSupervisors({String? departmentId, String? locationId}) async {
    if (!await PermissionService.checkNetwork()) {
      print('No network. Skipping supervisors fetch.');
      return [];
    }
    try {
      print('Fetching supervisors with departmentId: $departmentId, locationId: $locationId');
      var query = _supabase
          .from('users')
          .select('id, emp_code, name, role, department_id, geofence_id, department:departments(name), geofence:geofences!left(name)')
          .eq('role', 'supervisor');

      if (departmentId != null) {
        query = query.eq('department_id', departmentId);
      }
      if (locationId != null) {
        query = query.eq('geofence_id', locationId);
      }

      final response = await query;
      print('Supervisors response: $response');
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('Error fetching supervisors: $e');
      return [];
    }
  }

  Future<void> clockIn(String userId, double lat, double lon, String status) async {
    if (!await PermissionService.checkNetwork()) {
      print('No network. Cannot clock in online.');
      throw Exception('No network connection');
    }
    try {
      print('Clocking in for userId: $userId, lat: $lat, lon: $lon, status: $status');
      await _supabase.from('attendance_logs').insert({
        'user_id': userId,
        'clock_in_time': DateTime.now().toIso8601String(),
        'clock_in_lat': lat,
        'clock_in_lon': lon,
        'status': status,
      });
      print('Clock-in successful');
    } catch (e) {
      print('Error clocking in: $e');
      if (e.toString().contains('SocketException')) {
        print('Network error during clock-in');
      }
      rethrow;
    }
  }

  Future<void> clockOut(String logId, double lat, double lon, String status) async {
    if (!await PermissionService.checkNetwork()) {
      print('No network. Cannot clock out online.');
      throw Exception('No network connection');
    }
    try {
      print('Clocking out for logId: $logId, lat: $lat, lon: $lon, status: $status');
      String clockOutStatus;
      final now = DateTime.now();
      final endOfWorkDay = DateTime(now.year, now.month, now.day, 17, 0);
      if (now.isBefore(endOfWorkDay)) {
        clockOutStatus = 'early_exit';
      } else {
        clockOutStatus = 'completed';
      }
      await _supabase
          .from('attendance_logs')
          .update({
            'clock_out_time': DateTime.now().toIso8601String(),
            'clock_out_lat': lat,
            'clock_out_lon': lon,
            'status': clockOutStatus,
          })
          .eq('id', logId);
      print('Clock-out successful');
    } catch (e) {
      print('Error clocking out: $e');
      if (e.toString().contains('SocketException')) {
        print('Network error during clock-out');
      }
      rethrow;
    }
  }

  Future<List<AttendanceLog>> getAttendanceHistory(String userId) async {
    if (!await PermissionService.checkNetwork()) {
      print('No network. Skipping attendance history fetch.');
      return [];
    }
    try {
      print('Fetching attendance history for userId: $userId');
      final response = await _supabase
          .from('attendance_logs')
          .select()
          .eq('user_id', userId)
          .gte(
            'clock_in_time',
            DateTime.now().subtract(Duration(days: 30)).toIso8601String(),
          )
          .order('clock_in_time', ascending: false);
      print('Attendance history response: $response');
      return (response as List)
          .map((json) => AttendanceLog.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching attendance history: $e');
      if (e.toString().contains('SocketException')) {
        print('Network error during attendance history fetch');
      }
      return [];
    }
  }

  Future<List<AttendanceLog>> getFilteredAttendanceHistory(String userId, String filter) async {
    if (!await PermissionService.checkNetwork()) {
      print('No network. Skipping filtered attendance history fetch.');
      return [];
    }
    try {
      print('Fetching filtered attendance history for userId: $userId, filter: $filter');
      DateTime startDate;
      final now = DateTime.now();
      switch (filter) {
        case 'This Week':
          final daysFromMonday = now.weekday - 1;
          startDate = DateTime(now.year, now.month, now.day - daysFromMonday);
          break;
        case 'This Month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'All Time':
          startDate = DateTime.now().subtract(Duration(days: 365));
          break;
        default:
          startDate = DateTime.now().subtract(Duration(days: 30));
      }
      final response = await _supabase
          .from('attendance_logs')
          .select()
          .eq('user_id', userId)
          .gte('clock_in_time', startDate.toIso8601String())
          .order('clock_in_time', ascending: false);
      print('Filtered attendance history response: $response');
      return (response as List)
          .map((json) => AttendanceLog.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching filtered attendance history: $e');
      if (e.toString().contains('SocketException')) {
        print('Network error during filtered attendance history fetch');
      }
      return [];
    }
  }

  Future<List<AttendanceLog>> getMonthlyAttendanceHistory(String userId, int year, int month) async {
    if (!await PermissionService.checkNetwork()) {
      print('No network. Skipping monthly attendance history fetch.');
      return [];
    }
    try {
      print('Fetching monthly attendance history for userId: $userId, year: $year, month: $month');
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 1).subtract(Duration(seconds: 1));
      final response = await _supabase
          .from('attendance_logs')
          .select()
          .eq('user_id', userId)
          .gte('clock_in_time', startDate.toIso8601String())
          .lte('clock_in_time', endDate.toIso8601String())
          .order('clock_in_time', ascending: false);
      print('Monthly attendance history response: $response');
      return (response as List)
          .map((json) => AttendanceLog.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching monthly attendance history: $e');
      if (e.toString().contains('SocketException')) {
        print('Network error during monthly attendance history fetch');
      }
      return [];
    }
  }

  Future<List<AttendanceLog>> getDailyAttendanceHistory(String userId, DateTime date) async {
    if (!await PermissionService.checkNetwork()) {
      print('No network. Skipping daily attendance history fetch.');
      return [];
    }
    try {
      print('Fetching daily attendance history for userId: $userId, date: $date');
      final startDate = DateTime(date.year, date.month, date.day);
      final endDate = startDate.add(Duration(days: 1)).subtract(Duration(seconds: 1));
      final response = await _supabase
          .from('attendance_logs')
          .select()
          .eq('user_id', userId)
          .gte('clock_in_time', startDate.toIso8601String())
          .lte('clock_in_time', endDate.toIso8601String())
          .order('clock_in_time', ascending: false);
      print('Daily attendance history response: $response');
      return (response as List)
          .map((json) => AttendanceLog.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching daily attendance history: $e');
      if (e.toString().contains('SocketException')) {
        print('Network error during daily attendance history fetch');
      }
      return [];
    }
  }

  Future<bool> userExists(String empCode) async {
    if (!await PermissionService.checkNetwork()) {
      print('No network. Skipping user existence check.');
      return false;
    }
    try {
      print('Checking if user exists with emp_code: $empCode');
      final response = await _supabase
          .from('users')
          .select('id')
          .eq('emp_code', empCode)
          .maybeSingle();
      print('User exists response: $response');
      return response != null;
    } catch (e) {
      print('Error checking user existence: $e');
      if (e.toString().contains('SocketException')) {
        print('Network error during user existence check');
      }
      return false;
    }
  }

  Future<AttendanceLog?> getActiveLog(String userId) async {
    if (!await PermissionService.checkNetwork()) {
      print('No network. Skipping active log fetch.');
      return null;
    }
    try {
      print('\x1B[31mDEBUG: Fetching active log for userId: $userId\x1B[0m');
      final response = await _supabase
          .from('attendance_logs')
          .select()
          .eq('user_id', userId)
          .isFilter('clock_out_time', null)
          .order('clock_in_time', ascending: false)
          .limit(1);
      print('\x1B[31mDEBUG: Active log response: $response\x1B[0m');
      if (response.isNotEmpty) {
        final logData = response.first;
        print('\x1B[31mDEBUG: Found active log: $logData\x1B[0m');
        return AttendanceLog.fromJson(logData);
      } else {
        print('\x1B[31mDEBUG: No active log found\x1B[0m');
        return null;
      }
    } catch (e) {
      print('\x1B[31mError fetching active log: $e\x1B[0m');
      if (e.toString().contains('SocketException')) {
        print('Network error during active log fetch');
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserByEmpCode(String empCode) async {
    if (!await PermissionService.checkNetwork()) {
      print('No network. Skipping user fetch for emp_code: $empCode.');
      return null;
    }
    try {
      print('Fetching user with emp_code: $empCode');
      final response = await _supabase
          .from('users')
          .select()
          .eq('emp_code', empCode)
          .maybeSingle();
      print('User fetch response: $response');
      if (response == null) {
        print('No user found for emp_code: $empCode');
        return null;
      }
      return response;
    } catch (e) {
      print('Error fetching user by emp_code: $e');
      if (e.toString().contains('SocketException')) {
        print('Network error: Unable to connect to Supabase. URL: ${_supabase.rest.url}');
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserLocation(String empCode) async {
    if (!await PermissionService.checkNetwork()) {
      print('No network. Skipping user location fetch for emp_code: $empCode.');
      return null;
    }
    try {
      print('Fetching user location for emp_code: $empCode');
      final response = await _supabase
          .from('users')
          .select('lat, lon')
          .eq('emp_code', empCode)
          .maybeSingle();
      print('User location response: $response');
      return response;
    } catch (e) {
      print('Error fetching user location: $e');
      if (e.toString().contains('SocketException')) {
        print('Network error during user location fetch');
      }
      return null;
    }
  }

  Future<String?> getSupervisorNameByEmpCode(String empCode) async {
    if (!await PermissionService.checkNetwork()) {
      print('No network. Skipping supervisor name fetch for emp_code: $empCode.');
      return null;
    }
    try {
      print('Fetching supervisor name for emp_code: $empCode');
      final user = await _supabase
          .from('users')
          .select('supervisor_id')
          .eq('emp_code', empCode)
          .maybeSingle();
      print('User supervisor response: $user');
      if (user == null || user['supervisor_id'] == null) return null;
      final supervisor = await _supabase
          .from('users')
          .select('name, emp_code, role')
          .eq('id', user['supervisor_id'])
          .maybeSingle();
      print('Supervisor response: $supervisor');
      return supervisor != null ? supervisor['name'] as String : null;
    } catch (e) {
      print('Error fetching supervisor name: $e');
      if (e.toString().contains('SocketException')) {
        print('Network error during supervisor name fetch');
      }
      return null;
    }
  }

  Future<String?> getDepartmentNameById(String? departmentId) async {
    if (departmentId == null) {
      print('Department ID is null');
      return null;
    }
    if (!await PermissionService.checkNetwork()) {
      print('No network. Skipping department name fetch for department_id: $departmentId.');
      return null;
    }
    try {
      print('Fetching department name for department_id: $departmentId');
      final response = await _supabase
          .from('departments')
          .select('name')
          .eq('id', departmentId)
          .maybeSingle();
      print('Department fetch response: $response');
      return response != null ? response['name'] as String : null;
    } catch (e) {
      print('Error fetching department name: $e');
      if (e.toString().contains('SocketException')) {
        print('Network error during department name fetch');
      }
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getEmployeesBySupervisor(String supervisorEmpCode) async {
    if (!await PermissionService.checkNetwork()) {
      print('No network. Skipping employees fetch for supervisor: $supervisorEmpCode');
      return [];
    }
    try {
      print('Fetching employees under supervisor with emp_code: $supervisorEmpCode');
      final supervisor = await _supabase
          .from('users')
          .select('id, department_id')
          .eq('emp_code', supervisorEmpCode)
          .maybeSingle();
      if (supervisor == null) {
        print('Supervisor not found for emp_code: $supervisorEmpCode');
        return [];
      }
      final supervisorId = supervisor['id'];
      final departmentId = supervisor['department_id'];
      var employees = await _supabase
          .from('users')
          .select('id, emp_code, name, role, department_id, created_at, department:departments(name)')
          .eq('supervisor_id', supervisorId);
      if (employees.isEmpty && departmentId != null) {
        print('No employees with supervisor_id, falling back to department match.');
        employees = await _supabase
            .from('users')
            .select('id, emp_code, name, role, department_id, created_at, department:departments(name)')
            .eq('department_id', departmentId)
            .eq('role', 'employee');
      }
      print('Employees fetched: $employees');
      return List<Map<String, dynamic>>.from(employees as List);
    } catch (e) {
      print('Error fetching employees under supervisor: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllDepartments() async {
    if (!await PermissionService.checkNetwork()) {
      print('No network. Skipping departments fetch.');
      return [];
    }
    try {
      final response = await _supabase.from('departments').select('id, name');
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('Error fetching departments: $e');
      return [];
    }
  }

  Future<void> assignEmployeeToSupervisor(String empId, String supId) async {
    if (!await PermissionService.checkNetwork()) {
      print('No network. Cannot assign employee.');
      throw Exception('No network connection');
    }
    try {
      await _supabase.from('users').update({'supervisor_id': supId}).eq('id', empId);
      print('Employee assigned successfully');
    } catch (e) {
      print('Error assigning employee: $e');
      rethrow;
    }
  }

  Future<void> assignSupervisorToDepartment(String supId, String depId) async {
    if (!await PermissionService.checkNetwork()) {
      print('No network. Cannot assign department.');
      throw Exception('No network connection');
    }
    try {
      await _supabase.from('users').update({'department_id': depId}).eq('id', supId);
      print('Department assigned successfully');
    } catch (e) {
      print('Error assigning department: $e');
      rethrow;
    }
  }
}