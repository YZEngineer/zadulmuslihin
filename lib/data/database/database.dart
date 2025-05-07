import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// تعريف جداول قاعدة البيانات وإصداراتها
class AppDatabase {
  static const String databaseName = 'zadulmuslihin.db';
  static const int databaseVersion = 1;

  // أسماء الجداول
  static const String tableAdhanTimes = 'adhan_times';
  static const String tableAthkar = 'athkar';
  static const String tableCurrentAdhan = 'current_adhan';
  static const String tableCurrentLocation = 'current_location';
  static const String tableDailyTask = 'daily_tasks';
  static const String tableDailyWorship = 'daily_worship';
  static const String tableHadith = 'hadith';
  static const String tableIslamicInformation = 'islamic_information';
  static const String tableLocation = 'locations';
  static const String tableWorshipHistory = 'worship_history';
  static const String tableThoughtHistory = 'thought_history';
  static const String tableThought = 'thought';
  static const String tableQuranVerses = 'quran_verses';
  static const String tableDailyMessage = 'daily_message';
  static const String tableMyLibrary = 'my_library';
  static const String tableSettings = 'settings';

  /// إنشاء قاعدة البيانات
  static Future<Database> getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), databaseName),
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      version: databaseVersion,
    );
  }

  /// إنشاء جداول قاعدة البيانات
  static Future<void> _onCreate(Database db, int version) async {
    // ١. أولاً: إنشاء جدول المواقع
    await db.execute('''
      CREATE TABLE $tableLocation (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        city TEXT,
        country TEXT,
        timezone TEXT,
        madhab TEXT,
        method_id INTEGER NOT NULL)
    ''');

    // إدخال المواقع الأساسية
    final List<Map<String, dynamic>> defaultLocations = [
      {
        'latitude': 24.7136,
        'longitude': 46.6753,
        'city': "الرياض",
        'country': "المملكة العربية السعودية",
        'timezone': "Asia/Riyadh",
        'method_id': 1,
        'madhab': "Hanafi"
      },
      {
        'latitude': 21.4225,
        'longitude': 39.8262,
        'city': "مكة المكرمة",
        'country': "المملكة العربية السعودية",
        'timezone': "Asia/Riyadh",
        'method_id': 1,
        'madhab': "Hanafi"
      },
      {
        'latitude': 31.9552,
        'longitude': 35.9453,
        'city': "القدس",
        'country': "فلسطين",
        'timezone': "Asia/Jerusalem",
        'method_id': 1,
        'madhab': "Hanafi"
      }
    ];

    // إضافة المواقع الافتراضية
    for (var location in defaultLocations) {
      await db.insert(tableLocation, location);
    }

    // ٢. ثانياً: إنشاء جدول الموقع الحالي
    await db.execute('''
      CREATE TABLE $tableCurrentLocation (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        location_id INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (location_id) REFERENCES $tableLocation (id)
      )
    ''');

    // إنشاء سجل للموقع الحالي بقيمة افتراضية 1
    await db.insert(tableCurrentLocation, {'location_id': 1});

    // ٣. ثالثاً: إنشاء جدول أوقات الأذان
    await db.execute('''
      CREATE TABLE $tableAdhanTimes (
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
    ''');

    // ٤. رابعاً: إنشاء جدول الأذان الحالي
    await db.execute('''
      CREATE TABLE $tableCurrentAdhan (
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
    ''');

    // ٥. خامساً: إنشاء جدول الإعدادات
    await db.execute('''
      CREATE TABLE $tableSettings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT NOT NULL,
        value TEXT NOT NULL
      )
    ''');

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
    final List<Map<String, dynamic>> locations = await db.query(tableLocation);

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

    // تكملة إنشاء بقية الجداول

    // جدول الأذكار
    await db.execute('''
      CREATE TABLE $tableAthkar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL
      )
    ''');

    // جدول المهام اليومية
    await db.execute('''
      CREATE TABLE $tableDailyTask (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        is_completed INTEGER NOT NULL,
        is_on_working INTEGER NOT NULL,
        category INTEGER NOT NULL
      )
    ''');

    // جدول العبادات اليومية
    await db.execute('''
      CREATE TABLE $tableDailyWorship (
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
    ''');

    // جدول الأحاديث
    await db.execute('''
      CREATE TABLE $tableHadith (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        title TEXT NOT NULL,
        source TEXT NOT NULL
      )
    ''');

    // جدول المعلومات الإسلامية
    await db.execute('''
      CREATE TABLE $tableIslamicInformation (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT NOT NULL
      )
    ''');

    // جدول سجل العبادات
    await db.execute('''
      CREATE TABLE $tableWorshipHistory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        precentOf0 INTEGER NOT NULL,
        precentOf1 INTEGER NOT NULL,
        precentOf2 INTEGER NOT NULL,
        totalday INTEGER NOT NULL
      )
    ''');

    // جدول سجل الخواطر
    await db.execute('''
      CREATE TABLE $tableThoughtHistory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        precentOf0 INTEGER NOT NULL,
        precentOf1 INTEGER NOT NULL,
        precentOf2 INTEGER NOT NULL,
        totalday INTEGER NOT NULL
      )
    ''');

    // جدول الخواطر
    await db.execute('''
      CREATE TABLE $tableThought (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    // جدول آيات القرآن
    await db.execute('''
      CREATE TABLE $tableQuranVerses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL,
        source TEXT NOT NULL,
        theme TEXT
      )
    ''');

    // جدول الرسائل اليومية
    await db.execute('''
      CREATE TABLE $tableDailyMessage (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        date TEXT NOT NULL,
        category INTEGER NOT NULL,
        source TEXT NOT NULL
      )
    ''');

    // جدول مكتبتي
    await db.execute('''
      CREATE TABLE $tableMyLibrary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        source TEXT,
        tabName TEXT NOT NULL
      )
    ''');
  }

  /// ترقية قاعدة البيانات
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // سيتم تنفيذ هذا عند ترقية الإصدار
  }
}
