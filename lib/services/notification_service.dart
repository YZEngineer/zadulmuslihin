import 'package:flutter/material.dart';
import '../data/database/prayer_notification_dao.dart';
import '../data/models/prayer_notification.dart';

/// خدمة الإشعارات (نسخة مؤقتة مبسطة)
/// سيتم تفعيلها لاحقاً عند تثبيت المكتبات اللازمة
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  bool _isInitialized = false;
  final PrayerNotificationDao _prayerNotificationDao = PrayerNotificationDao();

  NotificationService._internal();

  /// تهيئة خدمة الإشعارات
  Future<void> init() async {
    try {
      if (_isInitialized) return;

      print('تم تهيئة خدمة الإشعارات (نسخة مبسطة مؤقتة)');
      _isInitialized = true;

      // التأكد من وجود إشعارات الصلاة في قاعدة البيانات
      await _ensurePrayerNotificationsExist();
    } catch (e) {
      print('خطأ في تهيئة خدمة الإشعارات: $e');
    }
  }

  /// التأكد من وجود إشعارات الصلاة في قاعدة البيانات
  Future<void> _ensurePrayerNotificationsExist() async {
    try {
      final notifications =
          await _prayerNotificationDao.getAllPrayerNotifications();
      if (notifications.isEmpty) {
        await _prayerNotificationDao.resetPrayerNotificationsToDefault();
        print('تم إنشاء إشعارات الصلاة الافتراضية');
      }
    } catch (e) {
      print('خطأ في التحقق من إشعارات الصلاة: $e');
    }
  }

  /// جدولة إشعارات الصلاة بناءً على مواقيت الصلاة لليوم
  Future<void> schedulePrayerNotifications({
    required Map<String, DateTime> prayerTimes,
  }) async {
    try {
      if (!_isInitialized) await init();

      final enabledNotifications =
          await _prayerNotificationDao.getEnabledPrayerNotifications();

      for (var notification in enabledNotifications) {
        switch (notification.prayerName) {
          case 'فجر':
            if (prayerTimes.containsKey('fajr')) {
              _schedulePrayerNotification(
                prayerName: 'الفجر',
                prayerTime: prayerTimes['fajr']!,
                minutesBefore: notification.minutesBefore,
              );
            }
            break;
          case 'ظهر':
            if (prayerTimes.containsKey('dhuhr')) {
              _schedulePrayerNotification(
                prayerName: 'الظهر',
                prayerTime: prayerTimes['dhuhr']!,
                minutesBefore: notification.minutesBefore,
              );
            }
            break;
          case 'عصر':
            if (prayerTimes.containsKey('asr')) {
              _schedulePrayerNotification(
                prayerName: 'العصر',
                prayerTime: prayerTimes['asr']!,
                minutesBefore: notification.minutesBefore,
              );
            }
            break;
          case 'مغرب':
            if (prayerTimes.containsKey('maghrib')) {
              _schedulePrayerNotification(
                prayerName: 'المغرب',
                prayerTime: prayerTimes['maghrib']!,
                minutesBefore: notification.minutesBefore,
              );
            }
            break;
          case 'عشاء':
            if (prayerTimes.containsKey('isha')) {
              _schedulePrayerNotification(
                prayerName: 'العشاء',
                prayerTime: prayerTimes['isha']!,
                minutesBefore: notification.minutesBefore,
              );
            }
            break;
        }
      }

      print('تم جدولة إشعارات الصلاة لليوم');
    } catch (e) {
      print('خطأ في جدولة إشعارات الصلاة: $e');
    }
  }

  /// جدولة إشعار لصلاة معينة
  Future<void> _schedulePrayerNotification({
    required String prayerName,
    required DateTime prayerTime,
    required int minutesBefore,
  }) async {
    // مؤقتاً نستخدم وسيلة عرض مبسطة
    print(
        'جدولة إشعار لصلاة $prayerName في ${prayerTime.toString()} (قبل $minutesBefore دقيقة)');

    // في المستقبل سنستخدم مكتبة flutter_local_notifications لجدولة الإشعارات الفعلية
  }

  /// إظهار إشعار فوري (لا يعمل حالياً - مؤقت)
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    print('إشعار جديد (لا يعمل حالياً): $title - $body');
  }

  /// جدولة إشعار في وقت محدد (لا يعمل حالياً - مؤقت)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    print('جدولة إشعار في $scheduledTime: $title - $body');
  }

  /// إلغاء إشعار معين
  Future<void> cancelNotification(int id) async {
    print('تم إلغاء الإشعار رقم $id');
  }

  /// إلغاء جميع الإشعارات
  Future<void> cancelAllNotifications() async {
    print('تم إلغاء جميع الإشعارات');
  }

  /// الحصول على جميع إعدادات إشعارات الصلاة
  Future<List<PrayerNotification>> getPrayerNotificationSettings() async {
    return await _prayerNotificationDao.getAllPrayerNotifications();
  }

  /// تحديث إعدادات إشعار صلاة
  Future<bool> updatePrayerNotification(PrayerNotification notification) async {
    final result =
        await _prayerNotificationDao.updatePrayerNotification(notification);
    return result > 0;
  }

  /// تحديث حالة تفعيل إشعار صلاة
  Future<bool> updatePrayerNotificationStatus(int id, bool isEnabled) async {
    final result = await _prayerNotificationDao.updatePrayerNotificationStatus(
        id, isEnabled);
    return result > 0;
  }

  /// إعادة تعيين إعدادات إشعارات الصلاة إلى الافتراضية
  Future<bool> resetPrayerNotificationsToDefault() async {
    return await _prayerNotificationDao.resetPrayerNotificationsToDefault();
  }
}
