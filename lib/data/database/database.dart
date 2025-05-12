import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// تعريف جداول قاعدة البيانات وإصداراتها

class AppDatabase {
  static const String databaseName = 'zadulmuslihin.db';
  static const int databaseVersion = 1;

  // أسماء الجداول
  static const String tableAdhanTimes = 'adhan_times';
  static const String tableCurrentAdhan = 'current_adhan';
  static const String tableCurrentLocation = 'current_location';
  static const String tableDailyTask = 'daily_tasks';
  static const String tableDailyWorship = 'daily_worship';
  static const String tableIslamicInformation = 'islamic_information';
  static const String tableLocation = 'locations';
  static const String tableWorshipHistory = 'worship_history';
  static const String tableThoughtHistory = 'thought_history';
  static const String tableThought = 'thought';
  static const String tableDailyMessage = 'daily_message';
  static const String tableMyLibrary = 'my_library';
  static const String tableSettings = 'settings';
  static const String tablePrayerNotifications = 'prayer_notifications';

  /// إنشاء قاعدة البيانات
  static Future<Database> getDatabase() async {
    try {
      print("جاري فتح قاعدة البيانات...");
      return await openDatabase(
        join(await getDatabasesPath(), databaseName),
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        version: databaseVersion,
      );
    } catch (e) {
      print("خطأ في فتح قاعدة البيانات: $e");
      rethrow;
    }
  }

  /// إنشاء جداول قاعدة البيانات
  static Future<void> _onCreate(Database db, int version) async {
    try {
      print("بدء إنشاء جداول قاعدة البيانات");

      // ١. أولاً: إنشاء جدول المواقع
      await _createTable(
          db,
          '''
        CREATE TABLE IF NOT EXISTS $tableLocation (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          city TEXT,
          country TEXT,
          timezone TEXT,
          madhab TEXT,
          method_id INTEGER NOT NULL)
      ''',
          'جدول المواقع');

      // ٢. ثانياً: إنشاء جدول الموقع الحالي
      await _createTable(
          db,
          '''
        CREATE TABLE IF NOT EXISTS $tableCurrentLocation (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          location_id INTEGER NOT NULL DEFAULT 1,
          FOREIGN KEY (location_id) REFERENCES $tableLocation (id)
        )
      ''',
          'جدول الموقع الحالي');

      // إنشاء سجل للموقع الحالي بقيمة افتراضية 1
      await db.insert(tableCurrentLocation, {'location_id': 1});

      // ٣. ثالثاً: إنشاء جدول أوقات الأذان
      await _createTable(
          db,
          '''
        CREATE TABLE IF NOT EXISTS $tableAdhanTimes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          location_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          fajr_time TEXT NOT NULL DEFAULT '00:00',
          sunrise_time TEXT NOT NULL DEFAULT '00:00',
          dhuhr_time TEXT NOT NULL DEFAULT '00:00',
          asr_time TEXT NOT NULL DEFAULT '00:00',
          maghrib_time TEXT NOT NULL DEFAULT '00:00',
          isha_time TEXT NOT NULL DEFAULT '00:00',
          UNIQUE(location_id, date),
          FOREIGN KEY (location_id) REFERENCES $tableLocation (id)
        )
      ''',
          'جدول أوقات الأذان');

      // ٤. رابعاً: إنشاء جدول الأذان الحالي
      await _createTable(
          db,
          '''
        CREATE TABLE IF NOT EXISTS $tableCurrentAdhan (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          location_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          fajr_time TEXT NOT NULL DEFAULT '00:00',
          sunrise_time TEXT NOT NULL DEFAULT '00:00',
          dhuhr_time TEXT NOT NULL DEFAULT '00:00',
          asr_time TEXT NOT NULL DEFAULT '00:00',
          maghrib_time TEXT NOT NULL DEFAULT '00:00',
          isha_time TEXT NOT NULL DEFAULT '00:00',
          FOREIGN KEY (location_id) REFERENCES $tableLocation (id)
        )
      ''',
          'جدول الأذان الحالي');

      // ٥. خامساً: إنشاء جدول الإعدادات
      await _createTable(
          db,
          '''
        CREATE TABLE IF NOT EXISTS $tableSettings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          key TEXT NOT NULL,
          value TEXT NOT NULL
        )
      ''',
          'جدول الإعدادات');

      // إضافة إعدادات افتراضية
      List<Map<String, dynamic>> defaultSettings = [
        {'key': 'notification_enabled', 'value': 'true'},
        {'key': 'prayer_alert', 'value': 'true'},
        {'key': 'dark_mode', 'value': 'false'}
      ];

      for (var setting in defaultSettings) {
        await db.insert(tableSettings, setting);
      }

      // التأكد من وجود سجل لكل موقع في جدول أوقات الأذان الحالية
      final now = DateTime.now().toIso8601String().split('T')[0];
      final List<Map<String, dynamic>> locations =
          await db.query(tableLocation);

      for (var location in locations) {
        int locationId = location['id'];

        // إضافة سجل في جدول أوقات الأذان لكل موقع للتاريخ الحالي
        // استخدام ConflictAlgorithm.replace لتجنب مشكلة UNIQUE constraint
        await db.insert(
            tableAdhanTimes,
            {
              'location_id': locationId,
              'date': now,
              'fajr_time': '00:00',
              'sunrise_time': '00:00',
              'dhuhr_time': '00:00',
              'asr_time': '00:00',
              'maghrib_time': '00:00',
              'isha_time': '00:00',
            },
            conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // جدول المهام اليومية
      await _createTable(
          db,
          '''
        CREATE TABLE IF NOT EXISTS $tableDailyTask (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          is_completed INTEGER NOT NULL,
          is_on_working INTEGER NOT NULL,
          category INTEGER NOT NULL
        )
      ''',
          'جدول المهام اليومية');

      // جدول العبادات اليومية
      await _createTable(
          db,
          '''
        CREATE TABLE IF NOT EXISTS $tableDailyWorship (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          fajr_prayer INTEGER NOT NULL,
          dhuhr_prayer INTEGER NOT NULL,
          asr_prayer INTEGER NOT NULL,
          maghrib_prayer INTEGER NOT NULL,
          isha_prayer INTEGER NOT NULL,
          thikr INTEGER NOT NULL,
          qiyam INTEGER NOT NULL,
          witr INTEGER NOT NULL,
          quran_reading INTEGER NOT NULL
        )
      ''',
          'جدول العبادات اليومية');

      // جدول المعلومات الإسلامية
      await _createTable(
          db,
          '''
        CREATE TABLE IF NOT EXISTS $tableIslamicInformation (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          category TEXT NOT NULL
        )
      ''',
          'جدول المعلومات الإسلامية');

      // جدول سجل العبادات
      await _createTable(
          db,
          '''
        CREATE TABLE IF NOT EXISTS $tableWorshipHistory (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          precentOf0 INTEGER NOT NULL,
          precentOf1 INTEGER NOT NULL,
          precentOf2 INTEGER NOT NULL,
          totalday INTEGER NOT NULL
        )
      ''',
          'جدول سجل العبادات');

      // جدول سجل الخواطر
      await _createTable(
          db,
          '''
        CREATE TABLE IF NOT EXISTS $tableThoughtHistory (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          precentOf0 INTEGER NOT NULL,
          precentOf1 INTEGER NOT NULL,
          precentOf2 INTEGER NOT NULL,
          totalday INTEGER NOT NULL
        )
      ''',
          'جدول سجل الخواطر');

      // جدول الخواطر
      await _createTable(
          db,
          '''
        CREATE TABLE IF NOT EXISTS $tableThought (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          category INTEGER NOT NULL,
          date TEXT NOT NULL
        )
      ''',
          'جدول الخواطر');

      // جدول الرسائل اليومية
      await _createTable(
          db,
          '''
        CREATE TABLE IF NOT EXISTS $tableDailyMessage (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          date TEXT NOT NULL,
          category INTEGER NOT NULL,
          source TEXT NOT NULL
        )
      ''',
          'جدول الرسائل اليومية');

      // جدول مكتبتي
      await _createTable(
          db,
          '''
        CREATE TABLE IF NOT EXISTS $tableMyLibrary (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          content TEXT NOT NULL,
          source TEXT,
          tabName TEXT NOT NULL,
          links TEXT,
          type TEXT NOT NULL,
          category TEXT
        )
      ''',
          'جدول مكتبتي');

      // جدول إشعارات الصلاة
      await _createTable(
          db,
          '''
        CREATE TABLE IF NOT EXISTS $tablePrayerNotifications (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          prayer_name TEXT NOT NULL,
          is_enabled INTEGER NOT NULL DEFAULT 1,
          minutes_before INTEGER NOT NULL DEFAULT 15,
          use_adhan INTEGER NOT NULL DEFAULT 1,
          custom_sound TEXT,
          vibration_pattern TEXT
        )
      ''',
          'جدول إشعارات الصلاة');

      // إضافة إشعارات افتراضية للصلوات الخمس
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
        await db.insert(tablePrayerNotifications, notification);
      }

      print("تم إنشاء جميع الجداول بنجاح");
    } catch (e) {
      print("خطأ في إنشاء جداول قاعدة البيانات: $e");
      rethrow; // إعادة إلقاء الاستثناء للتعامل معه على مستوى أعلى
    }
  }

  /// إنشاء جدول واحد مع معالجة الأخطاء
  static Future<void> _createTable(
      Database db, String sql, String tableName) async {
    try {
      print("جاري إنشاء $tableName...");
      await db.execute(sql);
      print("تم إنشاء $tableName بنجاح");
    } catch (e) {
      print("خطأ في إنشاء $tableName: $e");
      rethrow;
    }
  }

  /// ترقية قاعدة البيانات
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    try {
      print(
          "ترقية قاعدة البيانات من الإصدار $oldVersion إلى الإصدار $newVersion");
      // سيتم تنفيذ هذا عند ترقية الإصدار في المستقبل
    } catch (e) {
      print("خطأ في ترقية قاعدة البيانات: $e");
      rethrow;
    }
  }
}
