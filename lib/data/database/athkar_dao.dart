import '../models/athkar.dart';
import 'database.dart';
import 'database_helper.dart';

/// فئة للتعامل مع بيانات الأذكار في قاعدة البيانات
class AthkarDao {
  final _databaseHelper = DatabaseHelper.instance;
  final String _tableName = AppDatabase.tableAthkar;

  /// إدراج ذكر جديد
  Future<int> insert(Athkar athkar) async {
    return await _databaseHelper.insert(_tableName, athkar.toMap());}

  /// تحديث ذكر موجود
  Future<int> update(Athkar athkar) async {
    if (athkar.id == null) {throw ArgumentError('لا يمكن تحديث ذكر بدون معرف');}
    return await _databaseHelper.update(_tableName, athkar.toMap(), 'id = ?', [athkar.id]);}

  /// حذف ذكر بواسطة المعرف
  Future<int> delete(int id) async {return await _databaseHelper.delete(_tableName, 'id = ?', [id]);}

  /// الحصول على ذكر بواسطة المعرف
  Future<Athkar?> getById(int id) async {
    final result = await _databaseHelper.query(_tableName, where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) {return null;}
    return Athkar.fromMap(result.first);}

  /// الحصول على جميع الأذكار
  Future<List<Athkar>> getAll() async {
    final result = await _databaseHelper.query(_tableName);
    return result.map((map) => Athkar.fromMap(map)).toList();
  }

  /// الحصول على الأذكار حسب العنوان
  Future<List<Athkar>> getByTitle(String title) async {
    final result = await _databaseHelper.query(
      _tableName, where: 'title LIKE ?', whereArgs: ['%$title%']);
    return result.map((map) => Athkar.fromMap(map)).toList(); }

  /// الحصول على الأذكار حسب الفئة
  Future<List<Athkar>> getByCategory(String category) async {
    final result = await _databaseHelper.query(
      _tableName, where: 'category = ?', whereArgs: [category]);
    return result.map((map) => Athkar.fromMap(map)).toList();}

  /// الحصول على عدد الأذكار
  Future<int> getCount() async {
    final result = await _databaseHelper.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
    return result.first['count'] as int;}

  /// البحث في الأذكار
  Future<List<Athkar>> search(String keyword) async {
    final result = await _databaseHelper.query(
      _tableName, where: 'title LIKE ? OR content LIKE ?', whereArgs: ['%$keyword%', '%$keyword%']);
    return result.map((map) => Athkar.fromMap(map)).toList();}
}
