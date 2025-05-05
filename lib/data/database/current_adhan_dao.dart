import '../models/current_adhan.dart';
import 'database.dart';
import 'database_helper.dart';

/// فئة للتعامل مع بيانات الصلاة الحالية في قاعدة البيانات
class CurrentAdhanDao {
  final _databaseHelper = DatabaseHelper.instance;
  final String _tableName = AppDatabase.tableCurrentAdhan;

  /// إدراج أو تحديث بيانات الصلاة الحالية
  Future<int> insertOrUpdate(CurrentAdhan currentAdhan) async {
    // التحقق من وجود سجل أولاً
    final existingRecords = await getAll();

    if (existingRecords.isEmpty) {
      // إدراج سجل جديد
      return await _databaseHelper.insert(_tableName, currentAdhan.toMap());
    } else {
      // تحديث السجل القائم (نحتفظ بسجل واحد فقط)
      final existingId = existingRecords.first.id;
      var updatedAdhan = currentAdhan.copyWith(id: existingId);

      return await _databaseHelper
          .update(_tableName, updatedAdhan.toMap(), 'id = ?', [existingId]);
    }
  }

  /// الحصول على بيانات الصلاة الحالية
  Future<List<CurrentAdhan>> getAll() async {
    final result = await _databaseHelper.query(_tableName);
    return result.map((map) => CurrentAdhan.fromMap(map)).toList();
  }

  /// الحصول على الصلاة الحالية إن وجدت
  Future<CurrentAdhan?> getCurrent() async {
    final records = await getAll();
    if (records.isEmpty) {return null;}
    return records.first;
  }

  /// تحديث معلومات الصلاة الحالية
  Future<int> updateCurrentAdhan(CurrentAdhan updatedAdhan) async {
    final current = await getCurrent();
    if (current == null) {return 0;}

    return await _databaseHelper
        .update(_tableName, updatedAdhan.toMap(), 'id = ?', [current.id]);
  }

  /// حذف جميع السجلات
  Future<int> deleteAll() async {
    return await _databaseHelper.delete(_tableName, '', []);
  }
}
