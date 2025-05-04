import '../models/islamic_information.dart';
import 'database.dart';
import 'database_helper.dart';

/// فئة للتعامل مع بيانات المعلومات الإسلامية في قاعدة البيانات
class IslamicInformationDao {
  final _databaseHelper = DatabaseHelper.instance;
  final String _tableName = AppDatabase.tableIslamicInformation;

  /// إدراج معلومة إسلامية جديدة
  Future<int> insert(IslamicInformation info) async {
    return await _databaseHelper.insert(_tableName, info.toMap());
  }

  /// تحديث معلومة إسلامية موجودة
  Future<int> update(IslamicInformation info) async {
    if (info.id == null) {
      throw ArgumentError('لا يمكن تحديث معلومة بدون معرف');
    }

    return await _databaseHelper
        .update(_tableName, info.toMap(), 'id = ?', [info.id]);
  }

  /// حذف معلومة إسلامية بواسطة المعرف
  Future<int> delete(int id) async {
    return await _databaseHelper.delete(
      _tableName,
      'id = ?',
      [id],
    );
  }

  /// الحصول على معلومة إسلامية بواسطة المعرف
  Future<IslamicInformation?> getById(int id) async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) {
      return null;
    }

    return IslamicInformation.fromMap(result.first);
  }

  /// الحصول على جميع المعلومات الإسلامية
  Future<List<IslamicInformation>> getAll() async {
    final result = await _databaseHelper.query(_tableName);
    return result.map((map) => IslamicInformation.fromMap(map)).toList();
  }

  /// الحصول على المعلومات الإسلامية حسب العنوان
  Future<List<IslamicInformation>> getByTitle(String title) async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'title LIKE ?',
      whereArgs: ['%$title%'],
    );

    return result.map((map) => IslamicInformation.fromMap(map)).toList();
  }

  /// الحصول على المعلومات الإسلامية حسب الفئة
  Future<List<IslamicInformation>> getByCategory(String category) async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'category = ?',
      whereArgs: [category],
    );

    return result.map((map) => IslamicInformation.fromMap(map)).toList();
  }

  /// الحصول على المعلومات الإسلامية حسب المصدر
  Future<List<IslamicInformation>> getBySource(String source) async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'source = ?',
      whereArgs: [source],
    );

    return result.map((map) => IslamicInformation.fromMap(map)).toList();
  }

  /// الحصول على عدد المعلومات الإسلامية
  Future<int> getCount() async {
    final result = await _databaseHelper
        .rawQuery('SELECT COUNT(*) as count FROM $_tableName');

    return result.first['count'] as int;
  }

  /// البحث في المعلومات الإسلامية
  Future<List<IslamicInformation>> search(String keyword) async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'title LIKE ? OR content LIKE ? OR category LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%', '%$keyword%'],
    );

    return result.map((map) => IslamicInformation.fromMap(map)).toList();
  }

  /// الحصول على الفئات المتاحة
  Future<List<String>> getCategories() async {
    final result = await _databaseHelper.rawQuery(
        'SELECT DISTINCT category FROM $_tableName ORDER BY category ASC');

    return result.map((map) => map['category'] as String).toList();
  }
}
