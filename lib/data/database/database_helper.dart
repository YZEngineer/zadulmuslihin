import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'zadulmuslihin.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDatabase,
      onUpgrade: _onUpgradeDatabase,
    );
  }

  // دالة جديدة لإعادة تعيين قاعدة البيانات (مفيدة للتطوير والاختبار)
  Future<void> resetDatabase() async {
    String path = join(await getDatabasesPath(), 'zadulmuslihin.db');
    // حذف قاعدة البيانات الحالية
    await deleteDatabase(path);
    // إعادة تهيئة قاعدة البيانات
    _database = null;
    await database;
  }

  // دالة للتحقق من وجود جدول معين في قاعدة البيانات
  Future<bool> isTableExists(String tableName) async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
          [tableName]);
      return tables.isNotEmpty;
    } catch (e) {
      print('خطأ في التحقق من وجود الجدول $tableName: $e');
      return false;
    }
  }

  // دالة للتحقق من صحة قاعدة البيانات
  Future<bool> validateDatabase() async {
    try {
      Database db = await database;

      // التحقق من وجود الجداول الرئيسية
      List<String> requiredTables = [
        'adhan_times',
        'locations',
        'current_location',
        'current_adhan',
        'daily_tasks',
        'islamic_information',
        'hadiths',
        'athkar',
        'daily_prayers'
      ];

      for (String table in requiredTables) {
        if (!await isTableExists(table)) {
          print('جدول غير موجود: $table');
          return false;
        }
      }

      return true;
    } catch (e) {
      print('خطأ في التحقق من قاعدة البيانات: $e');
      return false;
    }
  }

  Future<void> _onUpgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // إضافة الجداول الجديدة للنسخة 2
      await _createLocationTables(db);
    }
    if (oldVersion < 3) {
      // إضافة جدول الأذان الحالي للنسخة 3
      await _createCurrentAdhanTable(db);
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Create Daily Tasks table
    await db.execute('''
      CREATE TABLE daily_tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        isCompleted INTEGER DEFAULT 0,
        date TEXT,
        time TEXT,
        category TEXT,
        priority INTEGER DEFAULT 0
      )
    ''');

    // Create Adhan Times table (simplified structure)
    await db.execute('''
      CREATE TABLE adhan_times(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        fajr_time TEXT NOT NULL,
        sunrise_time TEXT NOT NULL,
        dhuhr_time TEXT NOT NULL,
        asr_time TEXT NOT NULL,
        maghrib_time TEXT NOT NULL,
        isha_time TEXT NOT NULL,
        suhoor_time TEXT
      )
    ''');

    // Create Islamic Information table
    await db.execute('''
      CREATE TABLE islamic_information(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT,
        source TEXT
      )
    ''');

    // Create Hadith table
    await db.execute('''
      CREATE TABLE hadiths(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        narrator TEXT,
        source TEXT,
        book TEXT,
        chapter TEXT,
        hadithNumber TEXT
      )
    ''');

    // Create Athkar table
    await db.execute('''
      CREATE TABLE athkar(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        category TEXT,
        count INTEGER DEFAULT 1,
        fadl TEXT,
        source TEXT
      )
    ''');

    // Create Daily Prayers table
    await db.execute('''
      CREATE TABLE daily_prayers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        occasion TEXT,
        arabic TEXT,
        translation TEXT,
        source TEXT
      )
    ''');

    // إنشاء جداول المواقع
    if (version >= 2) {
      await _createLocationTables(db);
    }

    // إنشاء جدول الأذان الحالي
    if (version >= 3) {
      await _createCurrentAdhanTable(db);
    }
  }

  // دالة لإنشاء جداول المواقع
  Future<void> _createLocationTables(Database db) async {
    // إنشاء جدول المواقع
    await db.execute('''
      CREATE TABLE locations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        country TEXT,
        city TEXT,
        method_id INTEGER
      )
    ''');

    // إنشاء جدول الموقع الحالي
    await db.execute('''
      CREATE TABLE current_location(
        id INTEGER PRIMARY KEY CHECK (id = 1),
        location_id INTEGER NOT NULL,
        FOREIGN KEY (location_id) REFERENCES locations (id)
          ON DELETE RESTRICT
          ON UPDATE CASCADE
      )
    ''');
  }

  // دالة لإنشاء جدول الأذان الحالي
  Future<void> _createCurrentAdhanTable(Database db) async {
    await db.execute('''
      CREATE TABLE current_adhan(
        id INTEGER PRIMARY KEY CHECK (id = 1),
        date TEXT NOT NULL,
        fajr_time TEXT NOT NULL,
        sunrise_time TEXT NOT NULL,
        dhuhr_time TEXT NOT NULL,
        asr_time TEXT NOT NULL,
        maghrib_time TEXT NOT NULL,
        isha_time TEXT NOT NULL,
        suhoor_time TEXT
      )
    ''');
  }
}
