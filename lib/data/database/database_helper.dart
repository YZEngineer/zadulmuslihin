import 'package:sqflite/sqflite.dart';
import 'database.dart';
import 'package:path/path.dart';

/// مساعد قاعدة البيانات للعمليات العامة
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  /// الحصول على مثيل قاعدة البيانات
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await AppDatabase.getDatabase();
    return _database!;
  }

  /// إعادة تهيئة قاعدة البيانات
  Future<Database> reinitializeDatabase() async {
    _database = null;
    return await database;
  }

  /// إدراج سجل في الجدول
  Future<int> insert(String table, Map<String, dynamic> row) async {
    try {
      Database db = await database;
      return await db.insert(table, row);
    } catch (e) {
      print('خطأ في إدراج البيانات: $e');
      return -1;
    }
  }

  /// إدراج أو استبدال سجل في الجدول (للتعامل مع قيود UNIQUE)
  Future<int> insertOrReplace(String table, Map<String, dynamic> row) async {
    try {
      Database db = await database;
      return await db.insert(table, row,
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print('خطأ في إدراج أو استبدال البيانات: $e');
      return -1;
    }
  }

  /// تحديث سجل في الجدول
  Future<int> update(String table, Map<String, dynamic> row, String whereClause,
      List<dynamic> whereArgs) async {
    try {
      Database db = await database;
      return await db.update(table, row,
          where: whereClause, whereArgs: whereArgs);
    } catch (e) {
      print('خطأ في تحديث البيانات: $e');
      return -1;
    }
  }

  /// حذف سجل من الجدول
  Future<int> delete(
      String table, String whereClause, List<dynamic> whereArgs) async {
    try {
      Database db = await database;
      return await db.delete(table, where: whereClause, whereArgs: whereArgs);
    } catch (e) {
      print('خطأ في حذف البيانات: $e');
      return -1;
    }
  }

  /// استعلام عن سجلات من الجدول
  Future<List<Map<String, dynamic>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      Database db = await database;
      return await db.query(
        table,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      print('خطأ في استعلام البيانات: $e');
      return [];
    }
  }

  /// تنفيذ استعلام SQL مخصص
  Future<List<Map<String, dynamic>>> rawQuery(String sql,
      [List<dynamic>? arguments]) async {
    Database db = await database;
    return await db.rawQuery(sql, arguments);
  }

  /// الحصول على قائمة جميع الجداول في قاعدة البيانات
  Future<List<String>> getAllTables() async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%'");

      return tables.map((table) => table['name'] as String).toList();
    } catch (e) {
      print('خطأ في الحصول على قائمة الجداول: $e');
      return [];
    }
  }

  /// الحصول على هيكل الجدول (أسماء الأعمدة وأنواعها)
  Future<List<Map<String, dynamic>>> getTableStructure(String tableName) async {
    try {
      Database db = await database;
      return await db.rawQuery("PRAGMA table_info($tableName)");
    } catch (e) {
      print('خطأ في الحصول على هيكل الجدول: $e');
      return [];
    }
  }

  /// الحصول على بيانات جدول معين
  Future<List<Map<String, dynamic>>> getTableData(String tableName,
      {int limit = 50}) async {
    try {
      Database db = await database;
      return await db.query(tableName, limit: limit);
    } catch (e) {
      print('خطأ في الحصول على بيانات الجدول: $e');
      return [];
    }
  }

  /// حذف قاعدة البيانات وإعادة إنشائها
  Future<void> resetDatabase() async {
    Database db = await database;
    await db.close();
    _database = null;

    // حذف قاعدة البيانات وإعادة إنشائها
    String path = await getDatabasesPath();
    await deleteDatabase('$path/${AppDatabase.databaseName}');

    // إعادة فتح قاعدة البيانات
    _database = await AppDatabase.getDatabase();
  }
}
