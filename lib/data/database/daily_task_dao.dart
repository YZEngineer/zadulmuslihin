import '../models/daily_task.dart';
import 'database.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

/// فئة للتعامل مع بيانات المهام اليومية في قاعدة البيانات
class DailyTaskDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
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
    return await _databaseHelper.delete(_tableName, 'id = ?', [id]);
  }

  /// الحصول على جميع المهام
  Future<List<DailyTask>> getAll() async {
    final result =
        await _databaseHelper.query(_tableName, orderBy: 'date DESC');
    return result.map((map) => DailyTask.fromMap(map)).toList();
  }

  /// الحصول على عدد المهام
  Future<int> getCount() async {
    final result = await _databaseHelper
        .rawQuery('SELECT COUNT(*) as count FROM $_tableName');
    return result.first['count'] as int;
  }

  /// الحصول على المهام حسب الفئة
  Future<List<DailyTask>> getByCategory(String category) async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'date DESC',
    );

    return result.map((map) => DailyTask.fromMap(map)).toList();
  }

  /// الحصول على المهام حسب التكرار
  Future<List<DailyTask>> getByRepeatType(String repeatType) async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'repeat_type = ?',
      whereArgs: [repeatType],
      orderBy: 'date DESC',
    );

    return result.map((map) => DailyTask.fromMap(map)).toList();
  }

  /// الحصول على المهام المكتملة
  Future<List<DailyTask>> getCompleted() async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'completed = ?',
      whereArgs: [1],
      orderBy: 'date DESC',
    );

    return result.map((map) => DailyTask.fromMap(map)).toList();
  }

  /// الحصول على المهام غير المكتملة
  Future<List<DailyTask>> getIncomplete() async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'completed = ?',
      whereArgs: [0],
      orderBy: 'date DESC',
    );

    return result.map((map) => DailyTask.fromMap(map)).toList();
  }

  /// الحصول على المهام حسب تاريخ الاستحقاق
  Future<List<DailyTask>> getByDueDate(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final result = await _databaseHelper.query(
      _tableName,
      where: 'due_date LIKE ?',
      whereArgs: ['$formattedDate%'],
      orderBy: 'due_date ASC',
    );

    return result.map((map) => DailyTask.fromMap(map)).toList();
  }

  /// تحديث حالة الإكمال للمهمة
  Future<int> updateCompletionStatus(int id, bool completed) async {
    return await _databaseHelper.update(
      _tableName,
      {'completed': completed ? 1 : 0},
      'id = ?',
      [id],
    );
  }

  /// البحث في المهام
  Future<List<DailyTask>> search(String query) async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'date DESC',
    );

    return result.map((map) => DailyTask.fromMap(map)).toList();
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
}
