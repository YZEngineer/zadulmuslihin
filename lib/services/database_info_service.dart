import 'package:zadulmuslihin/data/database/database_helper.dart';

/// خدمة للحصول على معلومات قاعدة البيانات
class DatabaseInfoService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  /// الحصول على قائمة جميع الجداول
  Future<List<String>> getAllTables() async {
    return await _databaseHelper.getAllTables();
  }

  /// الحصول على قائمة جميع الجداول بما فيها جداول النظام
  Future<List<String>> getAllSystemTables() async {
    try {
      final db = await _databaseHelper.database;
      List<Map<String, dynamic>> tables = await db
          .rawQuery("SELECT name FROM sqlite_master WHERE type='table'");

      return tables.map((table) => table['name'] as String).toList();
    } catch (e) {
      print('خطأ في الحصول على قائمة جميع الجداول: $e');
      return [];
    }
  }

  /// الحصول على هيكل جدول محدد
  Future<List<Map<String, dynamic>>> getTableStructure(String tableName) async {
    return await _databaseHelper.getTableStructure(tableName);
  }

  /// الحصول على بيانات جدول معين
  Future<List<Map<String, dynamic>>> getTableData(String tableName,
      {int? limit}) async {
    try {
      return await _databaseHelper.query(tableName, limit: limit);
    } catch (e) {
      print('خطأ في الحصول على بيانات الجدول: $e');
      return [];
    }
  }

  /// الحصول على كامل بيانات جدول معين بدون قيود
  Future<List<Map<String, dynamic>>> getFullTableData(String tableName) async {
    try {
      // استخدام الاستعلام المباشر للحصول على جميع البيانات دون قيود
      final db = await _databaseHelper.database;
      return await db.query(tableName);
    } catch (e) {
      print('خطأ في الحصول على كامل بيانات الجدول: $e');
      return [];
    }
  }

  /// الحصول على عدد السجلات في جدول محدد
  Future<int> getTableRowCount(String tableName) async {
    final result = await _databaseHelper
        .rawQuery('SELECT COUNT(*) as count FROM $tableName');
    if (result.isNotEmpty) {
      return result.first['count'] as int;
    }
    return 0;
  }

  /// الحصول على ملخص حول جميع الجداول (اسم الجدول وعدد السجلات)
  Future<List<Map<String, dynamic>>> getTablesInfo() async {
    final tables = await getAllTables();
    List<Map<String, dynamic>> tableInfo = [];

    for (var table in tables) {
      int rowCount = await getTableRowCount(table);
      tableInfo.add({
        'name': table,
        'rows': rowCount,
        'isSystemTable': false,
      });
    }

    return tableInfo;
  }

  /// إضافة سجل جديد إلى جدول محدد
  Future<int> addRecord(String tableName, Map<String, dynamic> data) async {
    try {
      return await _databaseHelper.insert(tableName, data);
    } catch (e) {
      print('خطأ في إضافة سجل جديد: $e');
      return -1;
    }
  }

  /// حذف سجل من جدول محدد
  Future<int> deleteRecord(
      String tableName, String whereClause, List<dynamic> whereArgs) async {
    try {
      return await _databaseHelper.delete(tableName, whereClause, whereArgs);
    } catch (e) {
      print('خطأ في حذف السجل: $e');
      return -1;
    }
  }

  /// تعديل سجل في جدول محدد
  Future<int> updateRecord(
      String tableName, Map<String, dynamic> data, int id) async {
    try {
      return await _databaseHelper.update(tableName, data, 'id = ?', [id]);
    } catch (e) {
      print('خطأ في تعديل السجل: $e');
      return -1;
    }
  }

  /// الحصول على سجل واحد بواسطة المعرف
  Future<Map<String, dynamic>?> getRecordById(String tableName, int id) async {
    try {
      final records = await _databaseHelper.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (records.isEmpty) {
        return null;
      }

      return records.first;
    } catch (e) {
      print('خطأ في استرجاع السجل: $e');
      return null;
    }
  }

  /// الحصول على هيكل الجدول لاستخدامه في نموذج الإضافة
  Future<Map<String, String>> getTableColumnTypes(String tableName) async {
    final structure = await getTableStructure(tableName);
    Map<String, String> columnTypes = {};

    for (var column in structure) {
      final columnName = column['name'] as String;
      final columnType = column['type'] as String;
      columnTypes[columnName] = columnType;
    }

    return columnTypes;
  }
}
