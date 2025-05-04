import '../models/adhan_time.dart';
import 'database.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

/// فئة للتعامل مع بيانات أوقات الصلاة في قاعدة البيانات
class AdhanTimesDao {
  final _databaseHelper = DatabaseHelper.instance;
  final String _tableName = AppDatabase.tableAdhanTimes;

  /// إدراج وقت أذان جديد أو تحديث القائم
  Future<int> insertOrUpdate(AdhanTimes adhanTimes) async {
    // التحقق من وجود سجل بنفس التاريخ
    final existingRecords = await getByDate(adhanTimes.date);

    if (existingRecords.isEmpty) {
      // إدراج سجل جديد
      return await _databaseHelper.insert(_tableName, adhanTimes.toMap());
    } else {
      // تحديث السجل القائم
      return await _databaseHelper.update(_tableName, adhanTimes.toMap(),
          'date = ?', [DateFormat('yyyy-MM-dd').format(adhanTimes.date)]);
    }
  }

  /// الحصول على أوقات الأذان لتاريخ معين
  Future<List<AdhanTimes>> getByDate(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final result = await _databaseHelper.query(
      _tableName,
      where: 'date = ?',
      whereArgs: [formattedDate],
    );

    return result.map((map) => AdhanTimes.fromMap(map)).toList();
  }

  /// الحصول على أوقات الأذان لفترة زمنية
  Future<List<AdhanTimes>> getByDateRange(
      DateTime startDate, DateTime endDate) async {
    final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

    final result = await _databaseHelper.query(
      _tableName,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [formattedStartDate, formattedEndDate],
      orderBy: 'date ASC',
    );

    return result.map((map) => AdhanTimes.fromMap(map)).toList();
  }

  /// حذف أوقات الأذان لتاريخ معين
  Future<int> deleteByDate(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    return await _databaseHelper.delete(
      _tableName,
      'date = ?',
      [formattedDate],
    );
  }

  /// حذف جميع أوقات الأذان
  Future<int> deleteAll() async {
    return await _databaseHelper.delete(_tableName, '', []);
  }

  /// الحصول على أحدث أوقات أذان
  Future<AdhanTimes?> getLatest() async {
    final result = await _databaseHelper.query(
      _tableName,
      orderBy: 'date DESC',
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return AdhanTimes.fromMap(result.first);
  }
}
