import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/database/database_manager.dart';
import 'service_provider.dart';
import '../utils/time_helper.dart';

/// فئة لتهيئة الخدمات وقاعدة البيانات عند بدء التطبيق
class AppInitializer {
  static final AppInitializer _instance = AppInitializer._internal();
  static bool _isInitialized = false;

  final ServiceProvider _serviceProvider = ServiceProvider();

  factory AppInitializer() {
    return _instance;
  }

  AppInitializer._internal();

  /// الحصول على مزود الخدمات
  ServiceProvider get serviceProvider => _serviceProvider;

  /// تهيئة التطبيق
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      print('بدء تهيئة التطبيق...');

      // تهيئة قاعدة البيانات
      await DatabaseManager.instance.initializeDatabase();

      // تهيئة مزود الخدمات
      await _serviceProvider.initialize();

      // تحديث بيانات الأذان
      await _serviceProvider.adhanUpdater.updateAdhanData();

      // بدء التحديث الدوري
      _serviceProvider.adhanUpdater.startPeriodicUpdates();

      _isInitialized = true;
      print('تم تهيئة التطبيق بنجاح');
    } catch (e) {
      print('خطأ أثناء تهيئة التطبيق: $e');

      // في حالة الفشل، يمكن محاولة إصلاح قاعدة البيانات وإعادة المحاولة
      if (e.toString().contains('no such table')) {
        print('خطأ في قاعدة البيانات. جاري إعادة تعيينها...');
        await DatabaseManager.instance.resetDatabase();

        // إعادة المحاولة مرة واحدة
        try {
          await DatabaseManager.instance.initializeDatabase();
          await _serviceProvider.initialize();
          await _serviceProvider.adhanUpdater.updateAdhanData();
          _serviceProvider.adhanUpdater.startPeriodicUpdates();

          _isInitialized = true;
          print('تم تهيئة التطبيق بنجاح بعد إعادة تعيين قاعدة البيانات');
        } catch (e2) {
          print('فشل في إعادة تهيئة التطبيق: $e2');
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  /// دالة مساعدة للاستخدام في وحدة main.dart
  /// انتظار تهيئة قاعدة البيانات وثم بدء تطبيق Flutter
  static FutureOr<void> ensureInitialized() async {
    try {
      await AppInitializer().initialize();
    } catch (e) {
      // طباعة الخطأ ولكن استمرار تشغيل التطبيق
      if (kDebugMode) {
        print('فشل في تهيئة التطبيق: $e');
      }
    }
  }

  /// الحصول على تاريخ اليوم الحالي
  static String getToday() {
    return TimeHelper.getToday();
  }
}
