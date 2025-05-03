import 'package:intl/intl.dart';

/// نموذج يمثل الأذان الحالي (الأذان النشط حالياً)
class CurrentAdhan {
  final int? id;
  final DateTime date; // تاريخ اليوم بتنسيق YYYY-MM-DD
  final String fajrTime; // وقت أذان الفجر
  final String sunriseTime; // وقت الشروق
  final String dhuhrTime; // وقت أذان الظهر
  final String asrTime; // وقت أذان العصر
  final String maghribTime; // وقت أذان المغرب
  final String ishaTime; // وقت أذان العشاء
  final String? suhoorTime; // وقت السحور (اختياري)

  CurrentAdhan({
    this.id,
    required this.date,
    required this.fajrTime,
    required this.sunriseTime,
    required this.dhuhrTime,
    required this.asrTime,
    required this.maghribTime,
    required this.ishaTime,
    this.suhoorTime,
  }) {
    // التحقق من صحة صيغة أوقات الصلاة
    if (!isValidTimeFormat(fajrTime)) {
      throw FormatException('صيغة وقت الفجر غير صالحة: $fajrTime');
    }
    if (!isValidTimeFormat(sunriseTime)) {
      throw FormatException('صيغة وقت الشروق غير صالحة: $sunriseTime');
    }
    if (!isValidTimeFormat(dhuhrTime)) {
      throw FormatException('صيغة وقت الظهر غير صالحة: $dhuhrTime');
    }
    if (!isValidTimeFormat(asrTime)) {
      throw FormatException('صيغة وقت العصر غير صالحة: $asrTime');
    }
    if (!isValidTimeFormat(maghribTime)) {
      throw FormatException('صيغة وقت المغرب غير صالحة: $maghribTime');
    }
    if (!isValidTimeFormat(ishaTime)) {
      throw FormatException('صيغة وقت العشاء غير صالحة: $ishaTime');
    }
    if (suhoorTime != null && !isValidTimeFormat(suhoorTime!)) {
      throw FormatException('صيغة وقت السحور غير صالحة: $suhoorTime');
    }
  }

  /// التحقق من صحة صيغة الوقت
  static bool isValidTimeFormat(String time) {
    final RegExp timeRegex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
    return timeRegex.hasMatch(time);
  }

  /// إنشاء نموذج من خريطة بيانات
  factory CurrentAdhan.fromMap(Map<String, dynamic> map) {
    // معالجة التاريخ: يمكن أن يكون إما String أو DateTime
    DateTime dateTime;
    if (map['date'] is String) {
      dateTime = DateTime.parse(map['date']);
    } else if (map['date'] is DateTime) {
      dateTime = map['date'];
    } else {
      throw FormatException('صيغة التاريخ غير صالحة: ${map['date']}');
    }

    return CurrentAdhan(
      id: map['id'],
      date: dateTime,
      fajrTime: map['fajr_time'] ?? '00:00',
      sunriseTime: map['sunrise_time'] ?? '00:00',
      dhuhrTime: map['dhuhr_time'] ?? '00:00',
      asrTime: map['asr_time'] ?? '00:00',
      maghribTime: map['maghrib_time'] ?? '00:00',
      ishaTime: map['isha_time'] ?? '00:00',
      suhoorTime: map['suhoor_time'],
    );
  }

  /// تحويل النموذج إلى خريطة بيانات لحفظها في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'fajr_time': fajrTime,
      'sunrise_time': sunriseTime,
      'dhuhr_time': dhuhrTime,
      'asr_time': asrTime,
      'maghrib_time': maghribTime,
      'isha_time': ishaTime,
      'suhoor_time': suhoorTime,
    };
  }

  /// إنشاء نسخة معدلة من هذا النموذج
  CurrentAdhan copyWith({
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
    return CurrentAdhan(
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
    return 'CurrentAdhan(id: $id, date: ${DateFormat('yyyy-MM-dd').format(date)}, '
        'fajrTime: $fajrTime, sunriseTime: $sunriseTime, '
        'dhuhrTime: $dhuhrTime, asrTime: $asrTime, '
        'maghribTime: $maghribTime, ishaTime: $ishaTime, '
        'suhoorTime: $suhoorTime)';
  }
}
