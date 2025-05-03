import 'package:sqflite/sqflite.dart';
import '../models/current_adhan.dart';
import 'database_helper.dart';

class CurrentAdhanDao {
  final dbHelper = DatabaseHelper.instance;

  /// تعيين الأذان الحالي
  Future<void> setCurrentAdhan(CurrentAdhan currentAdhan) async {
    Database db = await dbHelper.database;

    // التحقق من وجود السجل
    var count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM current_adhan'));

    if (count != null && count > 0) {
      // تحديث السجل الموجود
      await db.update(
        'current_adhan',
        currentAdhan.toMap(),
        where: 'id = 1',
      );
    } else {
      // إدراج سجل جديد مع تعيين id = 1
      Map<String, dynamic> data = currentAdhan.toMap();
      data['id'] = 1;
      await db.insert('current_adhan', data);
    }
  }

  /// الحصول على الأذان الحالي
  Future<CurrentAdhan?> getCurrentAdhan() async {
    Database db = await dbHelper.database;
    var results = await db.query(
      'current_adhan',
      where: 'id = 1',
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return CurrentAdhan.fromMap(results.first);
  }

  /// مسح جدول الأذان الحالي
  Future<int> clearCurrentAdhan() async {
    Database db = await dbHelper.database;
    return await db.delete('current_adhan');
  }

  /// التحقق مما إذا كان هناك أذان حالي مخزن
  Future<bool> hasCurrentAdhan() async {
    Database db = await dbHelper.database;
    var count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM current_adhan'));

    return count != null && count > 0;
  }
}
