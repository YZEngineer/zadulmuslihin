import '../models/thought_history.dart';
import 'database.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

/// فئة للتعامل مع بيانات سجل الأفكار في قاعدة البيانات
class ThoughtHistoryDao {
  final _databaseHelper = DatabaseHelper.instance;
  final String _tableName = AppDatabase.tableThoughtHistory;

  /// إدراج سجل جديد في قاعدة البيانات
  Future<int> insert(ThoughtHistory history) async {
    return await _databaseHelper.insert(_tableName, history.toJson());
  }

  /// تحديث بيانات سجل موجود
  Future<int> update(ThoughtHistory history) async {
    if (history.id == null) {
      throw ArgumentError('لا يمكن تحديث سجل بدون معرف');
    }
    return await _databaseHelper
        .update(_tableName, history.toJson(), 'id = ?', [history.id]);
  }

  /// حذف سجل من قاعدة البيانات
  Future<int> delete(int id) async {
    return await _databaseHelper.delete(_tableName, 'id = ?', [id]);
  }

  /// الحصول على سجل بواسطة المعرف
  Future<ThoughtHistory?> getById(int id) async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) {
      return null;
    }

    return ThoughtHistory.fromJson(result.first);
  }

  /// الحصول على جميع السجلات
  Future<List<ThoughtHistory>> getAll() async {
    final result = await _databaseHelper.query(_tableName);
    return result.map((map) => ThoughtHistory.fromJson(map)).toList();
  }

  /// الحصول على سجل بناءً على التاريخ
  Future<ThoughtHistory?> getByDate(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final result = await _databaseHelper.query(
      _tableName,
      where: 'date = ?',
      whereArgs: [formattedDate],
    );

    if (result.isEmpty) {
      return null;
    }

    return ThoughtHistory.fromJson(result.first);
  }

  /// الحصول على سجلات ضمن فترة زمنية محددة
  Future<List<ThoughtHistory>> getByDateRange(
      DateTime startDate, DateTime endDate) async {
    final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

    final result = await _databaseHelper.query(
      _tableName,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [formattedStartDate, formattedEndDate],
    );

    return result.map((map) => ThoughtHistory.fromJson(map)).toList();
  }

  /// الحصول على آخر سجل تم إضافته
  Future<ThoughtHistory?> getLatest() async {
    final result = await _databaseHelper.query(
      _tableName,
      orderBy: 'id DESC',
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return ThoughtHistory.fromJson(result.first);
  }

  /// حذف جميع السجلات
  Future<int> deleteAll() async {
    return await _databaseHelper.delete(_tableName, '', []);
  }
}
