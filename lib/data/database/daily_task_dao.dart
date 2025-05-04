import '../models/daily_task.dart';
import 'database.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

/// فئة للتعامل مع بيانات المهام اليومية في قاعدة البيانات
class DailyTaskDao {
  final _databaseHelper = DatabaseHelper.instance;
  final String _tableName = AppDatabase.tableDailyTask;

  /// إدراج مهمة جديدة
  Future<int> insert(DailyTask task) async {
    return await _databaseHelper.insert(_tableName, task.toMap());
  }

  /// تحديث مهمة موجودة
  Future<int> update(DailyTask task) async {
    if (task.id == null) {
      throw ArgumentError('لا يمكن تحديث مهمة بدون معرف');
    }

    return await _databaseHelper
        .update(_tableName, task.toMap(), 'id = ?', [task.id]);
  }

  /// حذف مهمة بواسطة المعرف
  Future<int> delete(int id) async {
    return await _databaseHelper.delete(
      _tableName,
      'id = ?',
      [id],
    );
  }

  /// الحصول على مهمة بواسطة المعرف
  Future<DailyTask?> getById(int id) async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) {
      return null;
    }

    return DailyTask.fromMap(result.first);
  }

  /// الحصول على جميع المهام
  Future<List<DailyTask>> getAll() async {
    final result = await _databaseHelper.query(_tableName);
    return result.map((map) => DailyTask.fromMap(map)).toList();
  }

  /// الحصول على المهام حسب التاريخ
  Future<List<DailyTask>> getByDate(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final result = await _databaseHelper.query(
      _tableName,
      where: 'date = ?',
      whereArgs: [formattedDate],
    );

    return result.map((map) => DailyTask.fromMap(map)).toList();
  }

  /// الحصول على المهام حسب الفئة
  Future<List<DailyTask>> getByCategory(String category) async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'category = ?',
      whereArgs: [category],
    );

    return result.map((map) => DailyTask.fromMap(map)).toList();
  }

  /// الحصول على المهام حسب مستوى الأهمية
  Future<List<DailyTask>> getByImportance(int importance) async {
    final result = await _databaseHelper.query(_tableName,
        where: 'importance = ?', whereArgs: [importance], orderBy: 'date ASC');

    return result.map((map) => DailyTask.fromMap(map)).toList();
  }

  /// الحصول على المهام المكتملة
  Future<List<DailyTask>> getCompletedTasks() async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'is_completed = ?',
      whereArgs: [1],
    );

    return result.map((map) => DailyTask.fromMap(map)).toList();
  }

  /// الحصول على المهام غير المكتملة
  Future<List<DailyTask>> getIncompleteTasks() async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'is_completed = ?',
      whereArgs: [0],
    );

    return result.map((map) => DailyTask.fromMap(map)).toList();
  }

  /// تحديث حالة المهمة
  Future<int> updateTaskStatus(int id, bool isCompleted) async {
    return await _databaseHelper.update(
        _tableName, {'is_completed': isCompleted ? 1 : 0}, 'id = ?', [id]);
  }

  /// الحصول على عدد المهام
  Future<int> getCount() async {
    final result = await _databaseHelper
        .rawQuery('SELECT COUNT(*) as count FROM $_tableName');

    return result.first['count'] as int;
  }

  /// البحث في المهام
  Future<List<DailyTask>> search(String keyword) async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
    );

    return result.map((map) => DailyTask.fromMap(map)).toList();
  }
}
