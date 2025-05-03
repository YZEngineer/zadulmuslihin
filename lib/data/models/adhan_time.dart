/// نموذج يمثل أوقات الأذان ليوم واحد
class AdhanTimes {
  final int? id;
  final DateTime date; // تاريخ اليوم بتنسيق YYYY-MM-DD
  final String fajrTime; // وقت أذان الفجر
  final String sunriseTime; // وقت الشروق
  final String dhuhrTime; // وقت أذان الظهر
  final String asrTime; // وقت أذان العصر
  final String maghribTime; // وقت أذان المغرب
  final String ishaTime; // وقت أذان العشاء
  final String? suhoorTime; // وقت السحر (اختياري)

  AdhanTimes({
    this.id,
    required this.date,
    required this.fajrTime,
    required this.sunriseTime,
    required this.dhuhrTime,
    required this.asrTime,
    required this.maghribTime,
    required this.ishaTime,
    this.suhoorTime,
  });

  /// إنشاء نموذج من خريطة بيانات قاعدة البيانات
  factory AdhanTimes.fromMap(Map<String, dynamic> map) {
    // معالجة التاريخ: يمكن أن يكون إما String أو DateTime
    DateTime dateTime;
    if (map['date'] is String) {
      dateTime = DateTime.parse(map['date']);
    } else if (map['date'] is DateTime) {
      dateTime = map['date'];
    } else {
      throw FormatException('صيغة التاريخ غير صالحة: ${map['date']}');
    }

    return AdhanTimes(
      id: map['id'],
      date: dateTime,
      fajrTime: map['fajr_time'] ?? '',
      sunriseTime: map['sunrise_time'] ?? '',
      dhuhrTime: map['dhuhr_time'] ?? '',
      asrTime: map['asr_time'] ?? '',
      maghribTime: map['maghrib_time'] ?? '',
      ishaTime: map['isha_time'] ?? '',
      suhoorTime: map['suhoor_time'],
    );
  }

  /// تحويل النموذج إلى خريطة بيانات لحفظها في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(), // تحويل التاريخ إلى صيغة نصية ISO
      'fajr_time': fajrTime,
      'sunrise_time': sunriseTime,
      'dhuhr_time': dhuhrTime,
      'asr_time': asrTime,
      'maghrib_time': maghribTime,
      'isha_time': ishaTime,
      'suhoor_time': suhoorTime,
    };
  }

  /// التحقق من صحة صيغة الوقت
  static bool isValidTimeFormat(String time) {
    final RegExp timeRegex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
    return timeRegex.hasMatch(time);
  }

  /// إنشاء نسخة معدلة من هذا النموذج
  AdhanTimes copyWith({
    int? id,
    DateTime? date,
    String? fajrTime,
    String? sunriseTime,
    String? dhuhrTime,
    String? asrTime,
    String? maghribTime,
    String? ishaTime,
    String? suhoorTime,
  }) {
    return AdhanTimes(
      id: id ?? this.id,
      date: date ?? this.date,
      fajrTime: fajrTime ?? this.fajrTime,
      sunriseTime: sunriseTime ?? this.sunriseTime,
      dhuhrTime: dhuhrTime ?? this.dhuhrTime,
      asrTime: asrTime ?? this.asrTime,
      maghribTime: maghribTime ?? this.maghribTime,
      ishaTime: ishaTime ?? this.ishaTime,
      suhoorTime: suhoorTime ?? this.suhoorTime,
    );
  }

  @override
  String toString() {
    return 'AdhanTimes(id: $id, date: ${date.toIso8601String()}, '
        'fajrTime: $fajrTime, sunriseTime: $sunriseTime, '
        'dhuhrTime: $dhuhrTime, asrTime: $asrTime, '
        'maghribTime: $maghribTime, ishaTime: $ishaTime, '
        'suhoorTime: $suhoorTime)';
  }
}
