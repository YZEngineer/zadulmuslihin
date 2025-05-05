import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/database/database.dart';
import '../../data/database/database_helper.dart';

/// أداة فحص قاعدة البيانات لعرض محتويات الجداول
class DbInspector {
  /// فحص جميع الجداول وطباعة محتوياتها في الكونسول
  static Future<void> inspectAllTables() async {
    debugPrint('\n===== بدء فحص قاعدة البيانات =====');

    final tables = [
      AppDatabase.tableAdhanTimes,
      AppDatabase.tableAthkar,
      AppDatabase.tableCurrentAdhan,
      AppDatabase.tableCurrentLocation,
      AppDatabase.tableDailyTask,
      AppDatabase.tableDailyWorship,
      AppDatabase.tableHadith,
      AppDatabase.tableIslamicInformation,
      AppDatabase.tableLocation,
      AppDatabase.tableWorshipHistory,
      AppDatabase.tableThoughtHistory,
      AppDatabase.tableThought,
      AppDatabase.tableQuranVerses,
      AppDatabase.tableDailyMessage,
      AppDatabase.tableMyLibrary,
    ];

    for (final table in tables) {
      await inspectTable(table);
    }

    debugPrint('===== انتهى فحص قاعدة البيانات =====\n');
  }

  /// فحص محتوى جدول معين وعرضه في الكونسول
  static Future<void> inspectTable(String tableName) async {
    try {
      final db = await DatabaseHelper.instance.database;

      // التحقق من وجود الجدول
      final checkTable = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'");

      if (checkTable.isEmpty) {
        debugPrint('⚠️ جدول $tableName غير موجود في قاعدة البيانات');
        return;
      }

      // الحصول على بيانات الجدول
      final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $tableName'));

      debugPrint('\n📋 جدول: $tableName (${count ?? 0} سجل)');

      if (count == 0) {
        debugPrint('   لا توجد بيانات في هذا الجدول');
        return;
      }

      // الحصول على أعمدة الجدول
      final tableInfo = await db.rawQuery('PRAGMA table_info($tableName)');
      final columns =
          tableInfo.map((column) => column['name'] as String).toList();

      debugPrint('   أعمدة: ${columns.join(', ')}');

      // الحصول على البيانات (حد أقصى 20 سجل)
      final data = await db.query(tableName, limit: 20);

      // طباعة البيانات
      for (var i = 0; i < data.length; i++) {
        final row = data[i];
        debugPrint('   سجل ${i + 1}: ${_formatRow(row)}');
      }

      if ((count ?? 0) > 20) {
        debugPrint('   ... والمزيد (${(count ?? 0) - 20} سجل إضافي غير معروض)');
      }
    } catch (e) {
      debugPrint('❌ خطأ أثناء فحص جدول $tableName: $e');
    }
  }

  /// تنسيق بيانات الصف لطباعتها بشكل مقروء
  static String _formatRow(Map<String, dynamic> row) {
    final entries = row.entries.map((e) {
      final value = e.value == null ? 'null' : e.value.toString();
      // اقتصار النصوص الطويلة
      final displayValue =
          value.length > 50 ? '${value.substring(0, 47)}...' : value;
      return '${e.key}: $displayValue';
    }).toList();

    return '{${entries.join(', ')}}';
  }
}
