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
    // جدول أوقات الأذان
    await db.execute('''
      CREATE TABLE $tableAdhanTimes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        fajr_time TEXT NOT NULL,
        sunrise_time TEXT NOT NULL,
        dhuhr_time TEXT NOT NULL,
        asr_time TEXT NOT NULL,
        maghrib_time TEXT NOT NULL,
        isha_time TEXT NOT NULL
      )
    ''');

    // جدول الأذكار
    await db.execute('''
      CREATE TABLE $tableAthkar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL
      )
    ''');

    // جدول الأذان الحالي
    await db.execute('''
      CREATE TABLE $tableCurrentAdhan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        prayer_name TEXT NOT NULL,
        prayer_time TEXT NOT NULL,
        next_prayer_name TEXT NOT NULL,
        next_prayer_time TEXT NOT NULL,
        current_date TEXT NOT NULL
      )
    ''');

    // جدول الموقع الحالي
    await db.execute('''
      CREATE TABLE $tableCurrentLocation (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        city TEXT,
        country TEXT,
        timezone TEXT,
        calculation_method TEXT NOT NULL,
        Madhab TEXT NOT NULL
      )
    ''');

    // جدول المهام اليومية
    await db.execute('''
      CREATE TABLE $tableDailyTask (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        is_completed INTEGER NOT NULL,
        work_on INTEGER NOT NULL,
        category INTEGER NOT NULL
      )
    ''');

    // جدول العبادات اليومية
    await db.execute('''
      CREATE TABLE $tableDailyWorship (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
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

    // جدول المواقع
    await db.execute('''
      CREATE TABLE $tableLocation (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        city TEXT,
        country TEXT,
        timezone TEXT,
        calculation_method TEXT NOT NULL,
        adjustment_method TEXT NOT NULL
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
        day INTEGER NOT NULL
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
    if (oldVersion < 2) {
      // مثال على ترقية مستقبلية
    }
  }
}
