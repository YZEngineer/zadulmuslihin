import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../data/database/database.dart';
import '../../data/database/database_helper.dart';

class DatabaseInitializer {
  static final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  /// تهيئة قاعدة البيانات والتأكد من وجود الجداول
  static Future<bool> initializeDatabase() async {
    try {
      print("بدء فحص قاعدة البيانات...");
      final db = await _databaseHelper.database;

      // فحص الجداول الموجودة
      final tables = await db
          .rawQuery('SELECT name FROM sqlite_master WHERE type="table"');
      print("الجداول الموجودة: $tables");

      // التحقق من وجود الجداول الأساسية
      final neededTables = [
        AppDatabase.tableLocation,
        AppDatabase.tableCurrentLocation,
        AppDatabase.tableAdhanTimes,
        AppDatabase.tableCurrentAdhan,
        AppDatabase.tableSettings,
        AppDatabase.tableMyLibrary,
        AppDatabase.tablePrayerNotifications,
      ];

      bool needsRecreation = false;
      for (var tableName in neededTables) {
        if (!_isTableExists(tables, tableName)) {
          print("الجدول $tableName غير موجود!");
          needsRecreation = true;
          break;
        }
      }

      // إذا كانت هناك جداول مفقودة، نقوم بإعادة إنشاء قاعدة البيانات
      if (needsRecreation) {
        print("بعض الجداول مفقودة، جاري إعادة إنشاء قاعدة البيانات...");
        await _recreateDatabase();
        return true;
      }

      print("قاعدة البيانات سليمة");
      return true;
    } catch (e) {
      print("خطأ أثناء تهيئة قاعدة البيانات: $e");
      // محاولة إعادة إنشاء قاعدة البيانات كإجراء أخير
      try {
        await _recreateDatabase();
        return true;
      } catch (e2) {
        print("فشل في إعادة إنشاء قاعدة البيانات: $e2");
        return false;
      }
    }
  }

  /// إعادة ضبط قاعدة البيانات بالكامل وإعادة إنشائها
  static Future<bool> resetDatabase() async {
    try {
      print("بدء إعادة ضبط قاعدة البيانات...");
      await _recreateDatabase();
      return true;
    } catch (e) {
      print("خطأ في إعادة ضبط قاعدة البيانات: $e");
      return false;
    }
  }

  /// التحقق ما إذا كان الجدول موجود
  static bool _isTableExists(
      List<Map<String, Object?>> tables, String tableName) {
    for (var table in tables) {
      if (table['name'] == tableName) {
        return true;
      }
    }
    return false;
  }

  /// إعادة إنشاء قاعدة البيانات
  static Future<void> _recreateDatabase() async {
    try {
      print("بدء إعادة إنشاء قاعدة البيانات...");

      // إغلاق الاتصال الحالي
      final db = await _databaseHelper.database;
      await db.close();

      // حذف قاعدة البيانات القديمة
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, AppDatabase.databaseName);
      print("جاري حذف قاعدة البيانات في: $path");
      await deleteDatabase(path);
      print("تم حذف قاعدة البيانات السابقة");

      // إعادة إنشاء قاعدة البيانات
      print("جاري إعادة إنشاء قاعدة البيانات...");
      final newDb = await _databaseHelper.reinitializeDatabase();

      // التحقق من الإنشاء
      final tables = await newDb
          .rawQuery('SELECT name FROM sqlite_master WHERE type="table"');
      print("الجداول بعد إعادة الإنشاء: $tables");

      // إضافة البيانات الأولية
      await _seedInitialData(newDb);

      print("تم إعادة إنشاء قاعدة البيانات بنجاح");
    } catch (e) {
      print("حدث خطأ أثناء إعادة إنشاء قاعدة البيانات: $e");
      rethrow;
    }
  }

  /// تعبئة البيانات الأولية
  static Future<void> _seedInitialData(Database db) async {
    try {
      print("جاري تعبئة البيانات الأولية...");

      // إضافة موقع افتراضي (مكة المكرمة)
      final locationId = await db.insert(AppDatabase.tableLocation, {
        'latitude': 21.3891,
        'longitude': 39.8579,
        'city': 'مكة المكرمة',
        'country': 'المملكة العربية السعودية',
        'timezone': 'Asia/Riyadh',
        'madhab': 'شافعي',
        'method_id': 4 // طريقة أم القرى
      });

      print("تم إضافة الموقع الافتراضي بمعرف: $locationId");

      // إضافة إشارة للموقع الحالي
      await db.insert(
          AppDatabase.tableCurrentLocation, {'location_id': locationId});

      print("تم إضافة الموقع الحالي");

      // إضافة إعدادات افتراضية
      await db.insert(AppDatabase.tableSettings,
          {'key': 'notification_enabled', 'value': 'true'});

      await db.insert(
          AppDatabase.tableSettings, {'key': 'prayer_alert', 'value': 'true'});

      await db.insert(
          AppDatabase.tableSettings, {'key': 'dark_mode', 'value': 'false'});

      print("تم إضافة الإعدادات الافتراضية");

      // إضافة إشعارات الصلاة الافتراضية
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

      print("تم إضافة إشعارات الصلاة الافتراضية");
    } catch (e) {
      print("خطأ في تعبئة البيانات الأولية: $e");
    }
  }
}
