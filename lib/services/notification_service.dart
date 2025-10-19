
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:attendance_app/services/permission_service.dart';

// class NotificationRecord {
//   final int id;
//   final String title;
//   final String body;
//   final DateTime timestamp;

//   NotificationRecord({
//     required this.id,
//     required this.title,
//     required this.body,
//     required this.timestamp,
//   });

//   Map<String, dynamic> toMap() => {
//         'id': id,
//         'title': title,
//         'body': body,
//         'timestamp': timestamp.toUtc().toIso8601String(),
//       };

//   factory NotificationRecord.fromMap(Map<String, dynamic> map) {
//     return NotificationRecord(
//       id: map['id'],
//       title: map['title'],
//       body: map['body'],
//       timestamp: DateTime.parse(map['timestamp']).toLocal(),
//     );
//   }
// }

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   static Database? _db;
//   static const String _tableName = 'notifications';

//   static Future<void> initialize() async {
//     // ADDED: Request notification permission first
//     final hasPermission = await PermissionService.checkNotificationPermission();
//     if (!hasPermission) {
//       print('Notification permission not granted - notifications may not work');
//     }

//     // Initialize notification plugin
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
        
//     const InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);
//     await _notificationsPlugin.initialize(initializationSettings);

//     // Initialize database
//     final databasesPath = await getDatabasesPath();
//     final path = join(databasesPath, 'notifications.db');
//     _db = await openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) async {
//         await db.execute('''
//           CREATE TABLE $_tableName (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             title TEXT,
//             body TEXT,
//             timestamp TEXT
//           )
//         ''');
//       },
//     );
//   }

//   static Future<void> showNotification({
//     required String title,
//     required String body,
//   }) async {
//     // ADDED: Check permission before showing notification
//     final hasPermission = await PermissionService.checkNotificationPermission();
//     if (!hasPermission) {
//       print('Cannot show notification - permission not granted');
//       // Still save to database even if we can't show notification
//       await _saveNotification(title, body);
//       return;
//     }

//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'TopCity id',
//       'TopCity Notifications',
//       channelDescription: 'Notification channel for TopCity app',
//       importance: Importance.high,
//       priority: Priority.high,
//       showWhen: true,
//     );
//     const NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);
//     await _notificationsPlugin.show(
//       DateTime.now().millisecondsSinceEpoch % 10000, // Unique ID
//       title,
//       body,
//       platformChannelSpecifics,
//     );

//     // Save notification to database
//     await _saveNotification(title, body);
//   }

//   static Future<void> _saveNotification(String title, String body) async {
//     if (_db == null) await initialize();
//     await _db!.insert(_tableName, {
//       'title': title,
//       'body': body,
//       'timestamp': DateTime.now().toUtc().toIso8601String(),
//     });
//   }

//   static Future<List<NotificationRecord>> getNotifications(String filter) async {
//     if (_db == null) await initialize();
//     DateTime startDate;
//     final now = DateTime.now();
//     switch (filter) {
//       case 'Today':
//         startDate = DateTime(now.year, now.month, now.day);
//         break;
//       case 'Yesterday':
//         startDate = DateTime(now.year, now.month, now.day - 1);
//         break;
//       case 'All':
//         startDate = DateTime(2000, 1, 1); // Far enough in the past
//         break;
//       default:
//         return [];
//     }

//     try {
//       final maps = await _db!.query(
//         _tableName,
//         where: 'timestamp >= ?',
//         whereArgs: [startDate.toUtc().toIso8601String()],
//         orderBy: 'timestamp DESC',
//       );
//       return maps.map((map) => NotificationRecord.fromMap(map)).toList();
//     } catch (e) {
//       print('Error fetching notifications: $e');
//       return [];
//     }
//   }

//   static Future<void> deleteNotification(int id) async {
//     if (_db == null) await initialize();
//     try {
//       await _db!.delete(
//         _tableName,
//         where: 'id = ?',
//         whereArgs: [id],
//       );
//     } catch (e) {
//       print('Error deleting notification: $e');
//     }
//   }
  
//   static Future<void> clearAllNotifications() async {
//     if (_db == null) await initialize();
//     try {
//       await _db!.delete(_tableName); // Delete all records
//     } catch (e) {
//       print('Error clearing notifications: $e');
//     }
//   }
// }


import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:attendance_app/services/permission_service.dart';

class NotificationRecord {
  final int id;
  final String title;
  final String body;
  final DateTime timestamp;

  NotificationRecord({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'timestamp': timestamp.toUtc().toIso8601String(),
      };

  factory NotificationRecord.fromMap(Map<String, dynamic> map) {
    return NotificationRecord(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      timestamp: DateTime.parse(map['timestamp']).toLocal(),
    );
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static Database? _db;
  static const String _tableName = 'notifications';

  static Future<void> initialize() async {
    // ADDED: Request notification permission first
    final hasPermission = await PermissionService.checkNotificationPermission();
    if (!hasPermission) {
      print('Notification permission not granted - notifications may not work');
    }

    // Initialize notification plugin
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // Reverted to original
        
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(initializationSettings);

    // Initialize database
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'notifications.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            body TEXT,
            timestamp TEXT
          )
        ''');
      },
    );
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    // ADDED: Check permission before showing notification
    final hasPermission = await PermissionService.checkNotificationPermission();
    if (!hasPermission) {
      print('Cannot show notification - permission not granted');
      // Still save to database even if we can't show notification
      await _saveNotification(title, body);
      return;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'TopCity id',
      'TopCity Notifications',
      channelDescription: 'Notification channel for TopCity app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher', // Added explicit icon matching manifest
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch % 10000, // Unique ID
      title,
      body,
      platformChannelSpecifics,
    );

    // Save notification to database
    await _saveNotification(title, body);
  }

  static Future<void> _saveNotification(String title, String body) async {
    if (_db == null) await initialize();
    await _db!.insert(_tableName, {
      'title': title,
      'body': body,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    });
  }

  static Future<List<NotificationRecord>> getNotifications(String filter) async {
    if (_db == null) await initialize();
    DateTime startDate;
    final now = DateTime.now();
    switch (filter) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Yesterday':
        startDate = DateTime(now.year, now.month, now.day - 1);
        break;
      case 'All':
        startDate = DateTime(2000, 1, 1); // Far enough in the past
        break;
      default:
        return [];
    }

    try {
      final maps = await _db!.query(
        _tableName,
        where: 'timestamp >= ?',
        whereArgs: [startDate.toUtc().toIso8601String()],
        orderBy: 'timestamp DESC',
      );
      return maps.map((map) => NotificationRecord.fromMap(map)).toList();
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  static Future<void> deleteNotification(int id) async {
    if (_db == null) await initialize();
    try {
      await _db!.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }
  
  static Future<void> clearAllNotifications() async {
    if (_db == null) await initialize();
    try {
      await _db!.delete(_tableName); // Delete all records
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }
}