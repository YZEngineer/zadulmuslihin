import 'package:flutter/material.dart';
import '../data/models/prayer_notification.dart';
import '../services/notification_service.dart';

class PrayerNotificationsSettingsPage extends StatefulWidget {
  @override
  _PrayerNotificationsSettingsPageState createState() =>
      _PrayerNotificationsSettingsPageState();
}

class _PrayerNotificationsSettingsPageState
    extends State<PrayerNotificationsSettingsPage> {
  final NotificationService _notificationService = NotificationService();
  List<PrayerNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notifications =
          await _notificationService.getPrayerNotificationSettings();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      print('خطأ في تحميل إعدادات الإشعارات: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateNotificationStatus(
      PrayerNotification notification, bool isEnabled) async {
    try {
      final updated = notification.copyWith(isEnabled: isEnabled);
      final success =
          await _notificationService.updatePrayerNotification(updated);

      if (success) {
        setState(() {
          final index =
              _notifications.indexWhere((n) => n.id == notification.id);
          if (index != -1) {
            _notifications[index] = updated;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('تم تحديث إعدادات إشعار صلاة ${notification.prayerName}'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('خطأ في تحديث حالة الإشعار: $e');
    }
  }

  Future<void> _updateMinutesBefore(
      PrayerNotification notification, int minutesBefore) async {
    try {
      final updated = notification.copyWith(minutesBefore: minutesBefore);
      final success =
          await _notificationService.updatePrayerNotification(updated);

      if (success) {
        setState(() {
          final index =
              _notifications.indexWhere((n) => n.id == notification.id);
          if (index != -1) {
            _notifications[index] = updated;
          }
        });
      }
    } catch (e) {
      print('خطأ في تحديث وقت الإشعار: $e');
    }
  }

  Future<void> _resetToDefaults() async {
    try {
      final success =
          await _notificationService.resetPrayerNotificationsToDefault();
      if (success) {
        await _loadNotificationSettings();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إعادة تعيين إعدادات الإشعارات'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('خطأ في إعادة تعيين إعدادات الإشعارات: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إعدادات إشعارات الصلاة'),
        actions: [
          IconButton(
            icon: Icon(Icons.restore),
            tooltip: 'استعادة الإعدادات الافتراضية',
            onPressed: _resetToDefaults,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(child: Text('لا توجد إعدادات للإشعارات'))
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return _buildNotificationCard(notification);
                  },
                ),
    );
  }

  Widget _buildNotificationCard(PrayerNotification notification) {
    // ترجمة أسماء الصلوات
    final prayerDisplayName = {
          'فجر': 'صلاة الفجر',
          'ظهر': 'صلاة الظهر',
          'عصر': 'صلاة العصر',
          'مغرب': 'صلاة المغرب',
          'عشاء': 'صلاة العشاء',
        }[notification.prayerName] ??
        notification.prayerName;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  prayerDisplayName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: notification.isEnabled,
                  onChanged: (value) =>
                      _updateNotificationStatus(notification, value),
                  activeColor: Colors.green,
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('وقت التنبيه قبل الصلاة:'),
            SizedBox(height: 8),
            Slider(
              value: notification.minutesBefore.toDouble(),
              min: 0,
              max: 60,
              divisions: 12,
              label: '${notification.minutesBefore} دقيقة',
              onChanged: notification.isEnabled
                  ? (value) {
                      setState(() {
                        final index = _notifications
                            .indexWhere((n) => n.id == notification.id);
                        if (index != -1) {
                          _notifications[index] = notification.copyWith(
                              minutesBefore: value.round());
                        }
                      });
                    }
                  : null,
              onChangeEnd: notification.isEnabled
                  ? (value) {
                      _updateMinutesBefore(notification, value.round());
                    }
                  : null,
            ),
            Text(
              'قبل الأذان بـ ${notification.minutesBefore} دقيقة',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: notification.isEnabled ? Colors.black87 : Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.notifications_active, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  notification.useAdhan ? 'صوت الأذان' : 'صوت تنبيه عادي',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
