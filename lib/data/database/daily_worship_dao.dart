import '../models/daily_worship.dart';
import 'database.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

/// فئة للتعامل مع بيانات العبادات اليومية في قاعدة البيانات
class DailyWorshipDao {
  final _databaseHelper = DatabaseHelper.instance;
  final String _tableName = AppDatabase.tableDailyWorship;

  /// إدراج عبادة يومية جديدة أو تحديث القائمة
  Future<int> insert(DailyWorship dailyWorship) async {
    if (_tableName.isEmpty) {return await _databaseHelper.insert(_tableName,dailyWorship.toMap());}
    else{return await _databaseHelper.update(_tableName, dailyWorship.toMap(), 'id = ?', [1]);}

  }

  /// تحديث عبادة يومية موجودة
  Future<int> update(DailyWorship dailyWorship) async {
    return await _databaseHelper.update(_tableName, dailyWorship.toMap(), 'id = ?', [1]);}


  /// الحصول على جميع سجلات العبادات
  Future<List<DailyWorship>> getAll() async {
    final result = await _databaseHelper.query(_tableName);
    return result.map((map) => DailyWorship.fromMap(map)).toList();}

  /// تحديث حالة صلاة معينة
  Future<int> updatePrayerStatus(String prayerName, bool completed) async {
    // تحديث حالة الصلاة المحددة
    final value = completed ? 1 : 0;
    ///final columnName = '${prayerName.toLowerCase()}_prayer';

    final result = await _databaseHelper.update(_tableName, {prayerName: value},
        'id = ?', [1]); // استخدام معرّف ثابت = 1
    return result;
  }

  /// حذف سجل عبادة بواسطة المعرف
  Future<int> delete(int id) async {
    return await _databaseHelper.delete(_tableName, 'id = ?', [id]);
  }

  setAllWorship(int state) async {
    return await _databaseHelper.update(
        _tableName,
        {
          'fajr_prayer': state,
          'dhuhr_prayer': state,
          'asr_prayer': state,
          'maghrib_prayer': state,
          'isha_prayer': state,
          'quran_reading': state,
          'thikr': state,
          'witr': state,
          'qiyam': state,
        },
        'id = ?',
        [1]);
  }
}
