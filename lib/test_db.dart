import 'package:flutter/material.dart';
import 'data/models/daily_worship.dart';
import 'data/database/daily_worship_dao.dart';
import 'data/database/database_manager.dart';

/// دالة لاختبار قاعدة البيانات
Future<void> testDatabase() async {
  debugPrint('بدء اختبار قاعدة البيانات...');

  try {
    // تهيئة مدير قاعدة البيانات
    final databaseManager = DatabaseManager.instance;
    await databaseManager.initialize();
    debugPrint('تم تهيئة قاعدة البيانات بنجاح');

    // إنشاء DAO للعبادات اليومية
    final dailyWorshipDao = DailyWorshipDao();

    // إنشاء نموذج عبادات يومية
    final dailyWorship = DailyWorship(
      id: 1,
      fajrPrayer: true,
      dhuhrPrayer: true,
      asrPrayer: false,
      maghribPrayer: false,
      ishaPrayer: false,
      witr: false,
      qiyam: false,
      quran: false,
      thikr: false,
    );

    // إدراج العبادات اليومية
    final insertResult = await dailyWorshipDao.insert(dailyWorship);
    debugPrint('تم إدراج العبادات اليومية بنجاح، النتيجة: $insertResult');

    // استعلام عن العبادات اليومية
    final result = await dailyWorshipDao.getAll();
    if (result != null) {
      debugPrint('نتيجة الاستعلام: ${result.toString()}');

      // تحديث حالة صلاة العصر
      final updateResult =
          await dailyWorshipDao.updatePrayerStatus('asr_prayer', true);
      debugPrint('تم تحديث حالة صلاة العصر، النتيجة: $updateResult');

      // استعلام عن العبادات المحدثة
      final updatedResult = await dailyWorshipDao.getAll();
      if (updatedResult != null) {
        debugPrint('نتيجة الاستعلام بعد التحديث: ${updatedResult.toString()}');
        // إعادة تعيين جميع العبادات
        final resetResult = await dailyWorshipDao.setAllWorship(0);
        debugPrint('تم إعادة تعيين جميع العبادات، النتيجة: $resetResult');
        // استعلام بعد إعادة التعيين
        final resetQueryResult = await dailyWorshipDao.getAll();
        if (resetQueryResult != null) {
          debugPrint('نتيجة الاستعلام بعد إعادة التعيين: ${resetQueryResult.toString()}');}
      }
    } else {debugPrint('لم يتم العثور على عبادات يومية');}
  } catch (e) {debugPrint('حدث خطأ أثناء الاختبار: $e');}
  debugPrint('انتهى اختبار قاعدة البيانات');
}
