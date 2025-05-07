import '../models/quran_verses.dart';
import 'database.dart';
import 'database_helper.dart';

/// فئة للتعامل مع بيانات آيات القرآن في قاعدة البيانات
class QuranVersesDao {
  final _databaseHelper = DatabaseHelper.instance;
  final String _tableName = AppDatabase.tableQuranVerses;

  /// إدراج آية قرآنية جديدة
  Future<int> insert(QuranVerses verse) async {
    return await _databaseHelper.insert(_tableName, verse.toMap());
  }

  /// تحديث آية قرآنية موجودة
  Future<int> update(QuranVerses verse) async {
    if (verse.id == null) {throw ArgumentError('لا يمكن تحديث آية قرآنية بدون معرف');}
    return await _databaseHelper.update(_tableName, verse.toMap(), 'id = ?', [verse.id]);
  }

  /// حذف آية قرآنية بواسطة المعرف
  Future<int> delete(int id) async {
    return await _databaseHelper.delete(_tableName, 'id = ?', [id]);}

  /// الحصول على آية قرآنية بواسطة المعرف
  Future<QuranVerses?> getById(int id) async {
    final result = await _databaseHelper.query(_tableName, where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) {return null;}
    return QuranVerses.fromMap(result.first);  }

  /// الحصول على جميع الآيات القرآنية
  Future<List<QuranVerses>> getAll() async {
    final result = await _databaseHelper.query(_tableName);
    return result.map((map) => QuranVerses.fromMap(map)).toList();}

  /// الحصول على الآيات القرآنية حسب السورة
  Future<List<QuranVerses>> getBySurah(String surah) async {
    final result = await _databaseHelper.query(
      _tableName, where: 'surah = ?', whereArgs: [surah], orderBy: 'verse_number ASC');
    return result.map((map) => QuranVerses.fromMap(map)).toList(); }

  /// الحصول على آية قرآنية محددة حسب السورة ورقم الآية
  Future<QuranVerses?> getByVerseNumber(String surah, int verseNumber) async {
    final result = await _databaseHelper.query(
      _tableName,where: 'surah = ? AND verse_number = ?',whereArgs: [surah, verseNumber]);

    if (result.isEmpty) {return null;}
    return QuranVerses.fromMap(result.first);  }

  /// الحصول على الآيات القرآنية حسب الموضوع
  Future<List<QuranVerses>> getByTheme(String theme) async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'theme = ?',whereArgs: [theme],orderBy: 'surah ASC, verse_number ASC'  );
    return result.map((map) => QuranVerses.fromMap(map)).toList();  }

  /// الحصول على عدد الآيات القرآنية
  Future<int> getCount() async {
    final result = await _databaseHelper.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
    return result.first['count'] as int;  }

  /// البحث في الآيات القرآنية
  Future<List<QuranVerses>> search(String keyword) async {
    final result = await _databaseHelper.query(
      _tableName,where: 'text LIKE ? OR translation LIKE ? OR theme LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%', '%$keyword%'],orderBy: 'surah ASC, verse_number ASC'
    );  return result.map((map) => QuranVerses.fromMap(map)).toList();  }

  /// الحصول على قائمة السور المتاحة
  Future<List<String>> getAvailableSurahs() async {
    final result = await _databaseHelper
        .rawQuery('SELECT DISTINCT surah FROM $_tableName ORDER BY surah ASC');

    return result.map((map) => map['surah'] as String).toList();
  }

  /// الحصول على قائمة المواضيع المتاحة
  Future<List<String>> getAvailableThemes() async {
    final result = await _databaseHelper.rawQuery(
        'SELECT DISTINCT theme FROM $_tableName WHERE theme IS NOT NULL ORDER BY theme ASC');

    return result.map((map) => map['theme'] as String).toList();
  }

  /// الحصول على عدد الآيات في سورة محددة
  Future<int> getVerseCountInSurah(String surah) async {
    final result = await _databaseHelper.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName WHERE surah = ?', [surah]);

    return result.first['count'] as int;
  }
}
