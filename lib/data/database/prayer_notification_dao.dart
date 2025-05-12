import 'package:sqflite/sqflite.dart';
import 'package:zadulmuslihin/data/database/database.dart';
import 'package:zadulmuslihin/data/models/prayer_notification.dart';
import 'database_helper.dart';

/// DAO للتعامل مع إشعارات الصلاة
class PrayerNotificationDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  /// إضافة إشعار صلاة جديد
  Future<int> insertPrayerNotification(PrayerNotification notification) async {
    try {
      final db = await _databaseHelper.database;
      return await db.insert(
        AppDatabase.tablePrayerNotifications,
        notification.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('خطأ في إضافة إشعار صلاة: $e');
      return -1;
    }
  }

  /// تحديث إشعار صلاة
  Future<int> updatePrayerNotification(PrayerNotification notification) async {
    try {
      final db = await _databaseHelper.database;
      return await db.update(
        AppDatabase.tablePrayerNotifications,
        notification.toJson(),
        where: 'id = ?',
        whereArgs: [notification.id],
      );
    } catch (e) {
      print('خطأ في تحديث إشعار صلاة: $e');
      return -1;
    }
  }

  /// حذف إشعار صلاة
  Future<int> deletePrayerNotification(int id) async {
    try {
      final db = await _databaseHelper.database;
      return await db.delete(
        AppDatabase.tablePrayerNotifications,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('خطأ في حذف إشعار صلاة: $e');
      return -1;
    }
  }

  /// الحصول على إشعار صلاة واحد بواسطة المعرف
  Future<PrayerNotification?> getPrayerNotificationById(int id) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppDatabase.tablePrayerNotifications,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;
      return PrayerNotification.fromJson(maps.first);
    } catch (e) {
      print('خطأ في الحصول على إشعار صلاة: $e');
      return null;
    }
  }

  /// الحصول على إشعار صلاة بواسطة اسم الصلاة
  Future<PrayerNotification?> getPrayerNotificationByName(
      String prayerName) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppDatabase.tablePrayerNotifications,
        where: 'prayer_name = ?',
        whereArgs: [prayerName],
      );

      if (maps.isEmpty) return null;
      return PrayerNotification.fromJson(maps.first);
    } catch (e) {
      print('خطأ في الحصول على إشعار صلاة: $e');
      return null;
    }
  }

  /// الحصول على جميع إشعارات الصلاة
  Future<List<PrayerNotification>> getAllPrayerNotifications() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppDatabase.tablePrayerNotifications,
      );

      return List.generate(maps.length, (i) {
        return PrayerNotification.fromJson(maps[i]);
      });
    } catch (e) {
      print('خطأ في الحصول على إشعارات الصلاة: $e');
      return [];
    }
  }

  /// الحصول على إشعارات الصلاة المفعلة فقط
  Future<List<PrayerNotification>> getEnabledPrayerNotifications() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppDatabase.tablePrayerNotifications,
        where: 'is_enabled = ?',
        whereArgs: [1],
      );

      return List.generate(maps.length, (i) {
        return PrayerNotification.fromJson(maps[i]);
      });
    } catch (e) {
      print('خطأ في الحصول على إشعارات الصلاة المفعلة: $e');
      return [];
    }
  }

  /// تحديث حالة التفعيل لإشعار صلاة معين
  Future<int> updatePrayerNotificationStatus(int id, bool isEnabled) async {
    try {
      final db = await _databaseHelper.database;
      return await db.update(
        AppDatabase.tablePrayerNotifications,
        {'is_enabled': isEnabled ? 1 : 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('خطأ في تحديث حالة إشعار الصلاة: $e');
      return -1;
    }
  }

  /// إعادة تعيين إعدادات الإشعارات إلى الافتراضية
  Future<bool> resetPrayerNotificationsToDefault() async {
    try {
      final db = await _databaseHelper.database;

      // حذف جميع الإشعارات الحالية
      await db.delete(AppDatabase.tablePrayerNotifications);

      // إضافة الإشعارات الافتراضية
      List<Map<String, dynamic>> defaultPrayerNotifications = [
        {
          'prayer_name': 'فجر',
          'is_enabled': 1,
          'minutes_before': 15,
          'use_adhan': 1
        },
        {
          'prayer_name': 'ظهر',
          'is_enabled': 1,
          'minutes_before': 15,
          'use_adhan': 1
        },
        {
          'prayer_name': 'عصر',
          'is_enabled': 1,
          'minutes_before': 15,
          'use_adhan': 1
        },
        {
          'prayer_name': 'مغرب',
          'is_enabled': 1,
          'minutes_before': 15,
          'use_adhan': 1
        },
        {
          'prayer_name': 'عشاء',
          'is_enabled': 1,
          'minutes_before': 15,
          'use_adhan': 1
        },
      ];

      for (var notification in defaultPrayerNotifications) {
        await db.insert(AppDatabase.tablePrayerNotifications, notification);
      }

      return true;
    } catch (e) {
      print('خطأ في إعادة تعيين إشعارات الصلاة: $e');
      return false;
    }
  }
}
