import '../models/hadith.dart';
import 'database.dart';
import 'database_helper.dart';

/// فئة للتعامل مع بيانات الأحاديث في قاعدة البيانات
class HadithDao {
  final _databaseHelper = DatabaseHelper.instance;
  final String _tableName = AppDatabase.tableHadith;

  /// إدراج حديث جديد
  Future<int> insert(Hadith hadith) async {
    return await _databaseHelper.insert(_tableName, hadith.toMap());
  }

  /// تحديث حديث موجود
  Future<int> update(Hadith hadith) async {
    if (hadith.id == null) {throw ArgumentError('لا يمكن تحديث حديث بدون معرف');}
    return await _databaseHelper.update(_tableName, hadith.toMap(), 'id = ?', [hadith.id]);}

  /// حذف حديث بواسطة المعرف
  Future<int> delete(int id) async {return await _databaseHelper.delete(_tableName, 'id = ?', [id]);}

  /// الحصول على حديث بواسطة المعرف
  Future<Hadith?> getById(int id) async {
    final result = await _databaseHelper.query(_tableName, where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) {return null;}
    return Hadith.fromMap(result.first);  }

  /// الحصول على جميع الأحاديث
  Future<List<Hadith>> getAll() async {
    final result = await _databaseHelper.query(_tableName);
    return result.map((map) => Hadith.fromMap(map)).toList();}

  /// الحصول على أحاديث حسب العنوان
  Future<List<Hadith>> getByTitle(String title) async {
    final result = await _databaseHelper.query(
      _tableName, where: 'title LIKE ?', whereArgs: ['%$title%']);
    return result.map((map) => Hadith.fromMap(map)).toList();
  }

  /// الحصول على أحاديث حسب المصدر
  Future<List<Hadith>> getBySource(String source) async {
    final result = await _databaseHelper.query(
      _tableName, where: 'source = ?', whereArgs: [source]);
    return result.map((map) => Hadith.fromMap(map)).toList();  }

  /// الحصول على عدد الأحاديث
  Future<int> getCount() async {
    final result = await _databaseHelper
        .rawQuery('SELECT COUNT(*) as count FROM $_tableName');
    return result.first['count'] as int;  }

  /// البحث في الأحاديث
  Future<List<Hadith>> search(String keyword) async {
    final result = await _databaseHelper.query(
      _tableName, where: 'title LIKE ? OR content LIKE ? OR source LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%', '%$keyword%']);

    return result.map((map) => Hadith.fromMap(map)).toList();
  }
}
