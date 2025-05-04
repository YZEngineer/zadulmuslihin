import '../models/thought.dart';
import 'database.dart';
import 'database_helper.dart';

/// فئة للتعامل مع بيانات الأفكار في قاعدة البيانات
class ThoughtDao {
  final _databaseHelper = DatabaseHelper.instance;
  final String _tableName = AppDatabase.tableThought;

  /// إدراج فكرة جديدة في قاعدة البيانات
  Future<int> insert(Thought thought) async {
    return await _databaseHelper.insert(_tableName, thought.toJson());
  }

  /// تحديث بيانات فكرة موجودة
  Future<int> update(Thought thought) async {
    if (thought.id == null) {
      throw ArgumentError('لا يمكن تحديث فكرة بدون معرف');
    }
    return await _databaseHelper
        .update(_tableName, thought.toJson(), 'id = ?', [thought.id]);
  }

  /// حذف فكرة من قاعدة البيانات
  Future<int> delete(int id) async {
    return await _databaseHelper.delete(_tableName, 'id = ?', [id]);
  }

  /// الحصول على فكرة بواسطة المعرف
  Future<Thought?> getById(int id) async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) {
      return null;
    }

    return Thought.fromJson(result.first);
  }

  /// الحصول على جميع الأفكار
  Future<List<Thought>> getAll() async {
    final result = await _databaseHelper.query(_tableName);
    return result.map((map) => Thought.fromJson(map)).toList();
  }

  /// الحصول على الأفكار حسب الفئة
  Future<List<Thought>> getByCategory(int category) async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'category = ?',
      whereArgs: [category],
    );

    return result.map((map) => Thought.fromJson(map)).toList();
  }

  /// الحصول على الأفكار حسب اليوم
  Future<List<Thought>> getByDay(int day) async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'day = ?',
      whereArgs: [day],
    );

    return result.map((map) => Thought.fromJson(map)).toList();
  }

  /// البحث عن أفكار تحتوي على نص معين
  Future<List<Thought>> search(String query) async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return result.map((map) => Thought.fromJson(map)).toList();
  }

  /// حذف جميع الأفكار
  Future<int> deleteAll() async {
    return await _databaseHelper.delete(_tableName, '', []);
  }
}
