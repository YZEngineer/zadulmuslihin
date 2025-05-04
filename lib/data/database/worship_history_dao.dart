import '../models/worship_history.dart';
import 'database.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

/// فئة للتعامل مع بيانات سجل العبادات في قاعدة البيانات
class WorshipHistoryDao {
  final _databaseHelper = DatabaseHelper.instance;
  final String _tableName = AppDatabase.tableWorshipHistory;

  /// إدراج سجل عبادة جديد
  Future<int> insert(WorshipHistory history) async {
    return await _databaseHelper.insert(_tableName, history.toMap());
  }

  /// تحديث سجل عبادة موجود
  Future<int> update(WorshipHistory history) async {
    if (history.id == null) {
      throw ArgumentError('لا يمكن تحديث سجل عبادة بدون معرف');
    }

    return await _databaseHelper
        .update(_tableName, history.toMap(), 'id = ?', [history.id]);
  }

  /// حذف سجل عبادة بواسطة المعرف
  Future<int> delete(int id) async {
    return await _databaseHelper.delete(
      _tableName,
      'id = ?',
      [id],
    );
  }

  /// الحصول على سجل عبادة بواسطة المعرف
  Future<WorshipHistory?> getById(int id) async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) {
      return null;
    }

    return WorshipHistory.fromMap(result.first);
  }

  /// الحصول على جميع سجلات العبادات
  Future<List<WorshipHistory>> getAll() async {
    final result = await _databaseHelper.query(
      _tableName,
      orderBy: 'date DESC',
    );
    return result.map((map) => WorshipHistory.fromMap(map)).toList();
  }

  /// الحصول على سجلات العبادات حسب التاريخ
  Future<List<WorshipHistory>> getByDate(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final result = await _databaseHelper.query(
      _tableName,
      where: 'date = ?',
      whereArgs: [formattedDate],
      orderBy: 'id DESC',
    );

    return result.map((map) => WorshipHistory.fromMap(map)).toList();
  }

  /// الحصول على سجلات العبادات حسب النوع
  Future<List<WorshipHistory>> getByType(String type) async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );

    return result.map((map) => WorshipHistory.fromMap(map)).toList();
  }

  /// الحصول على سجلات العبادات في فترة زمنية محددة
  Future<List<WorshipHistory>> getByDateRange(
      DateTime startDate, DateTime endDate) async {
    final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

    final result = await _databaseHelper.query(
      _tableName,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [formattedStartDate, formattedEndDate],
      orderBy: 'date DESC',
    );

    return result.map((map) => WorshipHistory.fromMap(map)).toList();
  }

  /// الحصول على عدد سجلات العبادات
  Future<int> getCount() async {
    final result = await _databaseHelper
        .rawQuery('SELECT COUNT(*) as count FROM $_tableName');

    return result.first['count'] as int;
  }

  /// البحث في سجلات العبادات
  Future<List<WorshipHistory>> search(String keyword) async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'type LIKE ? OR details LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
      orderBy: 'date DESC',
    );

    return result.map((map) => WorshipHistory.fromMap(map)).toList();
  }

  /// الحصول على أنواع العبادات المتاحة
  Future<List<String>> getAvailableTypes() async {
    final result = await _databaseHelper
        .rawQuery('SELECT DISTINCT type FROM $_tableName ORDER BY type ASC');

    return result.map((map) => map['type'] as String).toList();
  }

  /// حذف سجلات العبادات قبل تاريخ معين
  Future<int> deleteBeforeDate(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    return await _databaseHelper.delete(
      _tableName,
      'date < ?',
      [formattedDate],
    );
  }
}
