class DailyWorship {
  final int id;
  final bool fajrPrayer;
  final bool dhuhrPrayer;
  final bool asrPrayer;
  final bool maghribPrayer;
  final bool ishaPrayer;
  final bool tahajjud;
  final bool qiyam;
  final bool quran;
  final bool thikr;

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
