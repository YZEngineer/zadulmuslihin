import '../models/daily_message.dart';
import 'database.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

/// فئة للتعامل مع بيانات الرسائل اليومية في قاعدة البيانات
class DailyMessageDao {
  final _databaseHelper = DatabaseHelper.instance;
  final String _tableName = AppDatabase.tableDailyMessage;

  /// إدراج رسالة يومية جديدة
  Future<int> insert(DailyMessage message) async {
    return await _databaseHelper.insert(_tableName, message.toMap());
  }

  /// تحديث رسالة يومية موجودة
  Future<int> update(DailyMessage message) async {
    return await _databaseHelper.update(
      _tableName,
      message.toMap(),
      'id = ?',
      [message.id],
    );
  }

  /// الحصول على رسالة يومية حسب المعرف
  Future<DailyMessage?> getById(int id) async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) {
      return null;
    }

    return DailyMessage.fromMap(result.first);
  }

  /// الحصول على جميع الرسائل اليومية
  Future<List<DailyMessage>> getAll() async {
    final result = await _databaseHelper.query(_tableName);
    return result.map((map) => DailyMessage.fromMap(map)).toList();
  }

  /// الحصول على الرسائل اليومية حسب التصنيف
  Future<List<DailyMessage>> getByCategory(int category) async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'category = ?',
      whereArgs: [category],
    );

    return result.map((map) => DailyMessage.fromMap(map)).toList();
  }

  /// الحصول على الرسائل اليومية حسب التاريخ
  Future<List<DailyMessage>> getByDate(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final result = await _databaseHelper.query(
      _tableName,
      where: 'date LIKE ?',
      whereArgs: ['$formattedDate%'],
    );

    return result.map((map) => DailyMessage.fromMap(map)).toList();
  }

  /// حذف رسالة يومية بواسطة المعرف
  Future<int> delete(int id) async {
    return await _databaseHelper.delete(
      _tableName,
      'id = ?',
      [id],
    );
  }
}
