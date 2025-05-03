import '../models/daily_worship.dart';
import 'database_helper.dart';
import 'database.dart';
import 'package:sqflite/sqflite.dart';

/// فئة مسؤولة عن عمليات قاعدة البيانات للعبادات اليومية
class DailyWorshipDao {
  final tableName = DatabaseConstants.TABLE_DAILY_WORSHIP;
  final int fixedId = 1; // المعرف الثابت للعبادات اليومية

  /// التحقق من وجود بيانات العبادات اليومية
  Future<bool> exists() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: '${DatabaseConstants.COLUMN_ID} = ?',
      whereArgs: [fixedId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// الحصول على بيانات العبادات اليومية
  Future<DailyWorship?> getDailyWorship() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: '${DatabaseConstants.COLUMN_ID} = ?',
      whereArgs: [fixedId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return DailyWorship.fromMap(_adaptFromDatabase(result.first));
    }
    return null;
  }

  /// إضافة أو تحديث العبادات اليومية
  Future<void> saveDailyWorship(DailyWorship dailyWorship) async {
    final db = await DatabaseHelper.instance.database;
    final bool exists = await this.exists();

    // إضافة تأكيد أن المعرف = 1
    final Map<String, dynamic> data = _adaptToDatabase(dailyWorship.toMap());
    data[DatabaseConstants.COLUMN_ID] = fixedId;

    if (exists) {
      // تحديث السجل الموجود
      await db.update(
        tableName,
        data,
        where: '${DatabaseConstants.COLUMN_ID} = ?',
        whereArgs: [fixedId],
      );
    } else {
      // إضافة سجل جديد
      await db.insert(tableName, data);
    }
  }

  /// حذف عبادة يومية
  Future<int> deleteDailyWorship(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      tableName,
      where: '${DatabaseConstants.COLUMN_ID} = ?',
      whereArgs: [id],
    );
  }

  /// الحصول على جميع العبادات اليومية
  Future<List<DailyWorship>> getAllDailyWorship() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);

    return List.generate(maps.length, (i) {
      return DailyWorship.fromMap(_adaptFromDatabase(maps[i]));
    });
  }

  /// الحصول على عبادة يومية محددة بواسطة المعرف
  Future<DailyWorship?> getDailyWorshipById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '${DatabaseConstants.COLUMN_ID} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return DailyWorship.fromMap(_adaptFromDatabase(maps.first));
    }
    return null;
  }

  /// الحصول على آخر عبادة يومية
  Future<DailyWorship?> getLatestDailyWorship() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: '${DatabaseConstants.COLUMN_ID} DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return DailyWorship.fromMap(_adaptFromDatabase(maps.first));
    }
    return null;
  }

  /// البحث عن العبادات اليومية
  Future<List<DailyWorship>> searchDailyWorship({
    bool? hasFajrPrayer,
    bool? hasDhuhrPrayer,
    bool? hasAsrPrayer,
    bool? hasMaghribPrayer,
    bool? hasIshaPrayer,
    bool? hasTahajjud,
    bool? hasQiyam,
    bool? hasQuran,
    bool? hasThikr,
    bool? hasSuhoor,
  }) async {
    final db = await DatabaseHelper.instance.database;

    List<String> conditions = [];
    List<dynamic> args = [];

    if (hasFajrPrayer != null) {
      conditions.add('${DatabaseConstants.COLUMN_FAJR_PRAYER} = ?');
      args.add(hasFajrPrayer ? 1 : 0);
    }

    if (hasDhuhrPrayer != null) {
      conditions.add('${DatabaseConstants.COLUMN_DHUHR_PRAYER} = ?');
      args.add(hasDhuhrPrayer ? 1 : 0);
    }

    if (hasAsrPrayer != null) {
      conditions.add('${DatabaseConstants.COLUMN_ASR_PRAYER} = ?');
      args.add(hasAsrPrayer ? 1 : 0);
    }

    if (hasMaghribPrayer != null) {
      conditions.add('${DatabaseConstants.COLUMN_MAGHRIB_PRAYER} = ?');
      args.add(hasMaghribPrayer ? 1 : 0);
    }

    if (hasIshaPrayer != null) {
      conditions.add('${DatabaseConstants.COLUMN_ISHA_PRAYER} = ?');
      args.add(hasIshaPrayer ? 1 : 0);
    }

    if (hasTahajjud != null) {
      conditions.add('${DatabaseConstants.COLUMN_TAHAJJUD} = ?');
      args.add(hasTahajjud ? 1 : 0);
    }

    if (hasQiyam != null) {
      conditions.add('${DatabaseConstants.COLUMN_QIYAM} = ?');
      args.add(hasQiyam ? 1 : 0);
    }

    if (hasQuran != null) {
      conditions.add('${DatabaseConstants.COLUMN_QURAN} = ?');
      args.add(hasQuran ? 1 : 0);
    }

    if (hasThikr != null) {
      conditions.add('${DatabaseConstants.COLUMN_THIKR} = ?');
      args.add(hasThikr ? 1 : 0);
    }

    if (hasSuhoor != null) {
      conditions.add('${DatabaseConstants.COLUMN_SUHOOR} = ?');
      args.add(hasSuhoor ? 1 : 0);
    }

    String whereClause =
        conditions.isNotEmpty ? conditions.join(' AND ') : '1=1';

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: whereClause,
      whereArgs: args,
    );

    return List.generate(maps.length, (i) {
      return DailyWorship.fromMap(_adaptFromDatabase(maps[i]));
    });
  }

  /// تعديل البيانات المستلمة من قاعدة البيانات لتتوافق مع نموذج البيانات
  Map<String, dynamic> _adaptFromDatabase(Map<String, dynamic> map) {
    return {
      'id': map[DatabaseConstants.COLUMN_ID],
      'fajrPrayer': map[DatabaseConstants.COLUMN_FAJR_PRAYER] == 1,
      'dhuhrPrayer': map[DatabaseConstants.COLUMN_DHUHR_PRAYER] == 1,
      'asrPrayer': map[DatabaseConstants.COLUMN_ASR_PRAYER] == 1,
      'maghribPrayer': map[DatabaseConstants.COLUMN_MAGHRIB_PRAYER] == 1,
      'ishaPrayer': map[DatabaseConstants.COLUMN_ISHA_PRAYER] == 1,
      'tahajjud': map[DatabaseConstants.COLUMN_TAHAJJUD] == 1,
      'qiyam': map[DatabaseConstants.COLUMN_QIYAM] == 1,
      'quran': map[DatabaseConstants.COLUMN_QURAN] == 1,
      'thikr': map[DatabaseConstants.COLUMN_THIKR] == 1,
      'suhoor': map[DatabaseConstants.COLUMN_SUHOOR] == 1,
    };
  }

  /// تعديل البيانات المرسلة إلى قاعدة البيانات لتتوافق مع هيكل الجدول
  Map<String, dynamic> _adaptToDatabase(Map<String, dynamic> map) {
    return {
      DatabaseConstants.COLUMN_ID: fixedId, // إضافة المعرف الثابت
      DatabaseConstants.COLUMN_FAJR_PRAYER: map['fajrPrayer'] ? 1 : 0,
      DatabaseConstants.COLUMN_DHUHR_PRAYER: map['dhuhrPrayer'] ? 1 : 0,
      DatabaseConstants.COLUMN_ASR_PRAYER: map['asrPrayer'] ? 1 : 0,
      DatabaseConstants.COLUMN_MAGHRIB_PRAYER: map['maghribPrayer'] ? 1 : 0,
      DatabaseConstants.COLUMN_ISHA_PRAYER: map['ishaPrayer'] ? 1 : 0,
      DatabaseConstants.COLUMN_TAHAJJUD: map['tahajjud'] ? 1 : 0,
      DatabaseConstants.COLUMN_QIYAM: map['qiyam'] ? 1 : 0,
      DatabaseConstants.COLUMN_QURAN: map['quran'] ? 1 : 0,
      DatabaseConstants.COLUMN_THIKR: map['thikr'] ? 1 : 0,
      DatabaseConstants.COLUMN_SUHOOR: map['suhoor'] ? 1 : 0,
    };
  }
}
