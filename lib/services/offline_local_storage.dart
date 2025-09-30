
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:attendance_app/models/attendance_log_models.dart';
import 'package:attendance_app/services/geo_fence_services.dart';
import 'package:attendance_app/services/permission_service.dart';
import 'package:attendance_app/services/superbase_services.dart';
import 'package:intl/intl.dart';

class OfflineAttendanceRecord {
  final String id;
  final String empCode;
  final DateTime? clockInTime;
  final double? clockInLat;
  final double? clockInLon;
  final DateTime? clockOutTime;
  final double? clockOutLat;
  final double? clockOutLon;
  final DateTime timestamp;
  final bool isSynced;

  OfflineAttendanceRecord({
    required this.id,
    required this.empCode,
    this.clockInTime,
    this.clockInLat,
    this.clockInLon,
    this.clockOutTime,
    this.clockOutLat,
    this.clockOutLon,
    required this.timestamp,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'emp_code': empCode,
        'clock_in_time': clockInTime?.toUtc().toIso8601String(),
        'clock_in_lat': clockInLat,
        'clock_in_lon': clockInLon,
        'clock_out_time': clockOutTime?.toUtc().toIso8601String(),
        'clock_out_lat': clockOutLat,
        'clock_out_lon': clockOutLon,
        'timestamp': timestamp.toUtc().toIso8601String(),
        'is_synced': isSynced ? 1 : 0,
      };

  factory OfflineAttendanceRecord.fromMap(Map<String, dynamic> map) {
    return OfflineAttendanceRecord(
      id: map['id'],
      empCode: map['emp_code'],
      clockInTime: map['clock_in_time'] != null
          ? DateTime.parse(map['clock_in_time']).toLocal()
          : null,
      clockInLat: map['clock_in_lat']?.toDouble(),
      clockInLon: map['clock_in_lon']?.toDouble(),
      clockOutTime: map['clock_out_time'] != null
          ? DateTime.parse(map['clock_out_time']).toLocal()
          : null,
      clockOutLat: map['clock_out_lat']?.toDouble(),
      clockOutLon: map['clock_out_lon']?.toDouble(),
      timestamp: DateTime.parse(map['timestamp']).toLocal(),
      isSynced: map['is_synced'] == 1,
    );
  }
}

class OfflineLocalStorageService extends GetxService {
  static const String _tableName = 'offline_attendance';
  late Database _db;
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  final GeoFenceService _geoFenceService = Get.find<GeoFenceService>();
  final RxString message = ''.obs;
  final Rx<Color> messageColor = Colors.blue.obs;

  Future<void> init() async {
    print('Initializing OfflineLocalStorageService...');
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'attendance.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            emp_code TEXT,
            clock_in_time TEXT,
            clock_in_lat REAL,
            clock_in_lon REAL,
            clock_out_time TEXT,
            clock_out_lat REAL,
            clock_out_lon REAL,
            timestamp TEXT,
            is_synced INTEGER
          )
        ''');
      },
    );
    await _cleanupOldRecords();
    _startSyncListener();
    print('OfflineLocalStorageService initialized');
  }

  Future<List<OfflineAttendanceRecord>> getUnsyncedRecords() async {
    return await _getRecordsSyncStatus(false);
  }

  Future<List<OfflineAttendanceRecord>> _getRecordsSyncStatus(bool isSynced) async {
    try {
      print('Fetching records with is_synced: $isSynced');
      final List<Map<String, Object?>> maps = await _db.query(
        _tableName,
        where: 'is_synced = ?',
        whereArgs: [isSynced ? 1 : 0],
      );
      final records = maps.map((map) => OfflineAttendanceRecord.fromMap(map as Map<String, dynamic>)).toList();
      print('Fetched ${records.length} records');
      return records;
    } catch (e) {
      print('Error fetching records: $e');
      return [];
    }
  }

  Future<void> _cleanupOldRecords() async {
    try {
      final twoMonthsAgo = DateTime.now().subtract(Duration(days: 60)).toUtc().toIso8601String();
      print('Cleaning up records older than: $twoMonthsAgo');
      final deleted = await _db.delete(
        _tableName,
        where: 'timestamp < ?',
        whereArgs: [twoMonthsAgo],
      );
      print('Deleted $deleted old records');
    } catch (e) {
      print('Error cleaning up old records: $e');
    }
  }

  Future<void> saveOfflineRecord({
    required String empCode,
    DateTime? clockInTime,
    double? clockInLat,
    double? clockInLon,
    DateTime? clockOutTime,
    double? clockOutLat,
    double? clockOutLon,
  }) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final record = OfflineAttendanceRecord(
        id: id,
        empCode: empCode,
        clockInTime: clockInTime,
        clockInLat: clockInLat,
        clockInLon: clockInLon,
        clockOutTime: clockOutTime,
        clockOutLat: clockOutLat,
        clockOutLon: clockOutLon,
        timestamp: DateTime.now(),
      );
      await _db.insert(_tableName, record.toMap());
      print('Saved offline record: $id for empCode: $empCode');
      message.value = 'Attendance record saved offline';
      messageColor.value = Colors.blue;
      await _printOfflineRecords();
    } catch (e) {
      print('Error saving offline record: $e');
      message.value = 'Error saving offline record: $e';
      messageColor.value = Colors.red;
    }
  }

  Future<void> _printOfflineRecords() async {
    try {
      final maps = await _db.query(_tableName);
      final recordList = maps.map((map) => OfflineAttendanceRecord.fromMap(map as Map<String, dynamic>)).toList();
      print('\x1B[34m=== Offline Attendance Records ===\x1B[0m');
      final timeFormat = DateFormat('yyyy-MM-dd hh:mm:ss a Z');
      for (var record in recordList) {
        print('\x1B[32mID: ${record.id}\x1B[0m');
        print('\x1B[32mEmployee Code: ${record.empCode}\x1B[0m');
        print(
            '\x1B[32mClock In: ${record.clockInTime != null ? timeFormat.format(record.clockInTime!.toLocal()) : 'N/A'}\x1B[0m');
        print(
            '\x1B[32mClock In Location: ${record.clockInLat ?? 'N/A'}, ${record.clockInLon ?? 'N/A'}\x1B[0m');
        print(
            '\x1B[32mClock Out: ${record.clockOutTime != null ? timeFormat.format(record.clockOutTime!.toLocal()) : 'N/A'}\x1B[0m');
        print(
            '\x1B[32mClock Out Location: ${record.clockOutLat ?? 'N/A'}, ${record.clockOutLon ?? 'N/A'}\x1B[0m');
        print('\x1B[32mTimestamp: ${timeFormat.format(record.timestamp.toLocal())}\x1B[0m');
        print('\x1B[32mSynced: ${record.isSynced}\x1B[0m');
        print('\x1B[34m------------------------\x1B[0m');
      }
    } catch (e) {
      print('Error printing offline records: $e');
    }
  }

  Future<void> syncRecords() async {
    final hasNetwork = await PermissionService.checkNetwork();
    print('Syncing records, network status: $hasNetwork');
    if (!hasNetwork) {
      message.value = 'no_internet_sync_later'.tr;
      messageColor.value = Colors.red;
      return;
    }

    try {
      final geofences = await _supabaseService.getGeofences();
      print('Geofences for sync: $geofences');
      final unsyncedRecords = await getUnsyncedRecords();
      print('Unsynced records to sync: ${unsyncedRecords.length}');

      for (var record in unsyncedRecords) {
        bool isValidLocation = false;

        if (record.clockInLat != null && record.clockInLon != null) {
          isValidLocation = _geoFenceService.isInsideGeofence(
            record.clockInLat!,
            record.clockInLon!,
            geofences,
          );
          print('Clock-in location valid for record ${record.id}: $isValidLocation');
        }

        if (isValidLocation && record.clockOutLat != null && record.clockOutLon != null) {
          isValidLocation = _geoFenceService.isInsideGeofence(
            record.clockOutLat!,
            record.clockOutLon!,
            geofences,
          );
          print('Clock-out location valid for record ${record.id}: $isValidLocation');
        }

        if (isValidLocation) {
          try {
            if (record.clockInTime != null && record.clockInLat != null && record.clockInLon != null) {
              final userData = await _supabaseService.getUserByEmpCode(record.empCode);
              print('User data for sync record ${record.id}: $userData');
              if (userData != null) {
                await _supabaseService.clockIn(
                  userData['id'].toString(),
                  record.clockInLat!,
                  record.clockInLon!,
                  'present',
                );
                print('Clock-in synced for record ${record.id}');
              }
            }

            if (record.clockOutTime != null && record.clockOutLat != null && record.clockOutLon != null) {
              final userData = await _supabaseService.getUserByEmpCode(record.empCode);
              print('User data for clock-out sync ${record.id}: $userData');
              if (userData != null) {
                final activeLog = await _supabaseService.getActiveLog(userData['id'].toString());
                print('Active log for clock-out sync ${record.id}: $activeLog');
                if (activeLog != null) {
                  await _supabaseService.clockOut(
                    activeLog.id,
                    record.clockOutLat!,
                    record.clockOutLon!,
                    'present',
                  );
                  print('Clock-out synced for record ${record.id}');
                }
              }
            }

            await _db.update(
              _tableName,
              {'is_synced': 1},
              where: 'id = ?',
              whereArgs: [record.id],
            );
            print('Marked record ${record.id} as synced');
            message.value = 'Record synced successfully';
            messageColor.value = Colors.green;
          } catch (e) {
            print('Error syncing record ${record.id}: $e');
            message.value = 'Error syncing record: $e';
            messageColor.value = Colors.red;
          }
        } else {
          print('Invalid location for record ${record.id}');
          message.value = 'Invalid location for record ID: ${record.id}. Cannot sync.';
          messageColor.value = Colors.red;
        }
      }
      await _printOfflineRecords();
    } catch (e) {
      print('Error during sync: $e');
      message.value = 'Error during sync: $e';
      messageColor.value = Colors.red;
    }
  }

  void _startSyncListener() {
    Connectivity().onConnectivityChanged.listen((result) async {
      print('Connectivity changed: $result');
      if (result != ConnectivityResult.none) {
        print('Attempting to sync offline records...');
        await syncRecords();
      }
    });
  }

  Future<List<AttendanceLog>> getLocalAttendanceHistory(String userId) async {
    try {
      final twoMonthsAgo = DateTime.now().subtract(Duration(days: 60)).toUtc().toIso8601String();
      print('Fetching local attendance history for userId: $userId, since: $twoMonthsAgo');
      final maps = await _db.query(
        _tableName,
        where: 'timestamp >= ?',
        whereArgs: [twoMonthsAgo],
      );
      final records = maps.map((map) => OfflineAttendanceRecord.fromMap(map as Map<String, dynamic>)).toList();
      print('Fetched ${records.length} local attendance records');
      return records
          .map((r) => AttendanceLog(
                id: r.id,
                userId: userId,
                clockInTime: r.clockInTime,
                clockInLat: r.clockInLat,
                clockInLon: r.clockInLon,
                clockOutTime: r.clockOutTime,
                clockOutLat: r.clockOutLat,
                clockOutLon: r.clockOutLon,
                durationMinutes: r.clockOutTime != null && r.clockInTime != null
                    ? r.clockOutTime!.difference(r.clockInTime!).inMinutes
                    : null,
                status: 'present',
              ))
          .toList();
    } catch (e) {
      print('Error fetching local attendance history: $e');
      return [];
    }
  }

  Future<void> clockInOffline({
    required String empCode,
    required double lat,
    required double lon,
  }) async {
    print('Clocking in offline for empCode: $empCode, lat: $lat, lon: $lon');
    await saveOfflineRecord(
      empCode: empCode,
      clockInTime: DateTime.now().toUtc(),
      clockInLat: lat,
      clockInLon: lon,
    );
  }

  Future<void> clockOutOffline({
    required String empCode,
    required double lat,
    required double lon,
  }) async {
    try {
      print('Clocking out offline for empCode: $empCode, lat: $lat, lon: $lon');
      final maps = await _db.query(
        _tableName,
        where: 'emp_code = ? AND clock_in_time IS NOT NULL AND clock_out_time IS NULL',
        whereArgs: [empCode],
        orderBy: 'timestamp DESC',
        limit: 1,
      );
      final latestRecord = maps.isNotEmpty ? OfflineAttendanceRecord.fromMap(maps.first as Map<String, dynamic>) : null;
      print('Latest record for clock-out: $latestRecord');

      if (latestRecord != null) {
        final updatedRecord = OfflineAttendanceRecord(
          id: latestRecord.id,
          empCode: latestRecord.empCode,
          clockInTime: latestRecord.clockInTime,
          clockInLat: latestRecord.clockInLat,
          clockInLon: latestRecord.clockInLon,
          clockOutTime: DateTime.now().toUtc(),
          clockOutLat: lat,
          clockOutLon: lon,
          timestamp: latestRecord.timestamp,
          isSynced: false,
        );
        await _db.update(
          _tableName,
          updatedRecord.toMap(),
          where: 'id = ?',
          whereArgs: [latestRecord.id],
        );
        print('Updated record ${latestRecord.id} with clock-out');
        message.value = 'Clock-out recorded offline';
        messageColor.value = Colors.blue;
        await _printOfflineRecords();
      } else {
        print('No active clock-in record found');
        message.value = 'No active clock-in record found for offline clock-out';
        messageColor.value = Colors.red;
      }
    } catch (e) {
      print('Error clocking out offline: $e');
      message.value = 'Error clocking out offline: $e';
      messageColor.value = Colors.red;
    }
  }
}