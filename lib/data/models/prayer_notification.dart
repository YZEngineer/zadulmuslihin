class PrayerNotification {
  final int? id;
  final String prayerName; // اسم الصلاة: فجر، ظهر، عصر، مغرب، عشاء
  final bool isEnabled; // هل الإشعار مفعل
  final int minutesBefore; // الوقت قبل الصلاة بالدقائق للتذكير
  final bool useAdhan; // هل يستخدم صوت الأذان
  final String? customSound; // مسار الصوت المخصص إذا وجد
  final String? vibrationPattern; // نمط الاهتزاز

  PrayerNotification({
    this.id,
    required this.prayerName,
    this.isEnabled = true,
    this.minutesBefore = 15,
    this.useAdhan = true,
    this.customSound,
    this.vibrationPattern,
  });

  // إنشاء كائن من JSON
  factory PrayerNotification.fromJson(Map<String, dynamic> json) {
    return PrayerNotification(
      id: json['id'],
      prayerName: json['prayer_name'],
      isEnabled: json['is_enabled'] == 1,
      minutesBefore: json['minutes_before'],
      useAdhan: json['use_adhan'] == 1,
      customSound: json['custom_sound'],
      vibrationPattern: json['vibration_pattern'],
    );
  }

  // تحويل الكائن إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prayer_name': prayerName,
      'is_enabled': isEnabled ? 1 : 0,
      'minutes_before': minutesBefore,
      'use_adhan': useAdhan ? 1 : 0,
      'custom_sound': customSound,
      'vibration_pattern': vibrationPattern,
    };
  }

  // نسخة جديدة من الكائن مع تغييرات
  PrayerNotification copyWith({
    int? id,
    String? prayerName,
    bool? isEnabled,
    int? minutesBefore,
    bool? useAdhan,
    String? customSound,
    String? vibrationPattern,
  }) {
    return PrayerNotification(
      id: id ?? this.id,
      prayerName: prayerName ?? this.prayerName,
      isEnabled: isEnabled ?? this.isEnabled,
      minutesBefore: minutesBefore ?? this.minutesBefore,
      useAdhan: useAdhan ?? this.useAdhan,
      customSound: customSound ?? this.customSound,
      vibrationPattern: vibrationPattern ?? this.vibrationPattern,
    );
  }

  @override
  String toString() {
    return 'PrayerNotification(id: $id, prayerName: $prayerName, isEnabled: $isEnabled, minutesBefore: $minutesBefore)';
  }
}
