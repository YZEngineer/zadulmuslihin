/// نموذج يمثل العبادات اليومية للمستخدم
class DailyWorship {
  final int id;
  final bool fajrPrayer; // صلاة الفجر
  final bool dhuhrPrayer; // صلاة الظهر
  final bool asrPrayer; // صلاة العصر
  final bool maghribPrayer; // صلاة المغرب
  final bool ishaPrayer; // صلاة العشاء
  final bool tahajjud; // صلاة التهجد
  final bool qiyam; // قيام الليل
  final bool quran; // قراءة القرآن
  final bool thikr; // الأذكار

  DailyWorship({
    this.id = 1,
    required this.fajrPrayer,
    required this.dhuhrPrayer,
    required this.asrPrayer,
    required this.maghribPrayer,
    required this.ishaPrayer,
    required this.tahajjud,
    required this.qiyam,
    required this.quran,
    required this.thikr,
  });

  /// إنشاء نموذج من خريطة بيانات قاعدة البيانات
  factory DailyWorship.fromMap(Map<String, dynamic> map) {
    return DailyWorship(
      id: map['id'] ?? 1,
      fajrPrayer: map['fajrPrayer'] == 1 || map['fajrPrayer'] == true,
      dhuhrPrayer: map['dhuhrPrayer'] == 1 || map['dhuhrPrayer'] == true,
      asrPrayer: map['asrPrayer'] == 1 || map['asrPrayer'] == true,
      maghribPrayer: map['maghribPrayer'] == 1 || map['maghribPrayer'] == true,
      ishaPrayer: map['ishaPrayer'] == 1 || map['ishaPrayer'] == true,
      tahajjud: map['tahajjud'] == 1 || map['tahajjud'] == true,
      qiyam: map['qiyam'] == 1 || map['qiyam'] == true,
      quran: map['quran'] == 1 || map['quran'] == true,
      thikr: map['thikr'] == 1 || map['thikr'] == true,
    );
  }

  /// تحويل النموذج إلى خريطة بيانات لحفظها في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fajrPrayer': fajrPrayer ? 1 : 0,
      'dhuhrPrayer': dhuhrPrayer ? 1 : 0,
      'asrPrayer': asrPrayer ? 1 : 0,
      'maghribPrayer': maghribPrayer ? 1 : 0,
      'ishaPrayer': ishaPrayer ? 1 : 0,
      'tahajjud': tahajjud ? 1 : 0,
      'qiyam': qiyam ? 1 : 0,
      'quran': quran ? 1 : 0,
      'thikr': thikr ? 1 : 0,
    };
  }

  /// إنشاء نسخة معدلة من هذا النموذج
  DailyWorship copyWith({
    int? id,
    bool? fajrPrayer,
    bool? dhuhrPrayer,
    bool? asrPrayer,
    bool? maghribPrayer,
    bool? ishaPrayer,
    bool? tahajjud,
    bool? qiyam,
    bool? quran,
    bool? thikr,
  }) {
    return DailyWorship(
      id: id ?? this.id,
      fajrPrayer: fajrPrayer ?? this.fajrPrayer,
      dhuhrPrayer: dhuhrPrayer ?? this.dhuhrPrayer,
      asrPrayer: asrPrayer ?? this.asrPrayer,
      maghribPrayer: maghribPrayer ?? this.maghribPrayer,
      ishaPrayer: ishaPrayer ?? this.ishaPrayer,
      tahajjud: tahajjud ?? this.tahajjud,
      qiyam: qiyam ?? this.qiyam,
      quran: quran ?? this.quran,
      thikr: thikr ?? this.thikr,
    );
  }

  @override
  String toString() {
    return 'DailyWorship(id: $id, fajrPrayer: $fajrPrayer, dhuhrPrayer: $dhuhrPrayer, '
        'asrPrayer: $asrPrayer, maghribPrayer: $maghribPrayer, ishaPrayer: $ishaPrayer, '
        'tahajjud: $tahajjud, qiyam: $qiyam, quran: $quran, thikr: $thikr)';
  }
}
