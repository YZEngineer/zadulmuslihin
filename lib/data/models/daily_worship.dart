class Prayer {
  final bool farz;
  final bool sunnah;
  final bool inMosque;

  Prayer({
    required this.farz,
    required this.sunnah,
    required this.inMosque,
  });

  factory Prayer.fromMap(Map<String, dynamic> map) {
    return Prayer(
      farz: map['farz'] ?? false,
      sunnah: map['sunnah'] ?? false,
      inMosque: map['inMosque'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'farz': farz,
      'sunnah': sunnah,
      'inMosque': inMosque,
    };
  }
}

class DailyWorship {
  final int? id;
  final Prayer fajrPrayer;
  final Prayer dhuhrPrayer;
  final Prayer asrPrayer;
  final Prayer maghribPrayer;
  final Prayer ishaPrayer;
  final bool suhoor;
  final bool tahajjud;
  final bool qiyam;
  final bool quran;
  final bool thikr;
  final DateTime date;

  DailyWorship({
    this.id,
    required this.fajrPrayer,
    required this.dhuhrPrayer,
    required this.asrPrayer,
    required this.maghribPrayer,
    required this.ishaPrayer,
    required this.suhoor,
    required this.tahajjud,
    required this.qiyam,
    required this.quran,
    required this.thikr,
    required this.date,
  });

  factory DailyWorship.fromMap(Map<String, dynamic> map) {
    return DailyWorship(
      id: map['id'],
      fajrPrayer: Prayer.fromMap(map['fajrPrayer']),
      dhuhrPrayer: Prayer.fromMap(map['dhuhrPrayer']),
      asrPrayer: Prayer.fromMap(map['asrPrayer']),
      maghribPrayer: Prayer.fromMap(map['maghribPrayer']),
      ishaPrayer: Prayer.fromMap(map['ishaPrayer']),
      suhoor: map['suhoor'] ?? false,
      tahajjud: map['tahajjud'] ?? false,
      qiyam: map['qiyam'] ?? false,
      quran: map['quran'] ?? false,
      thikr: map['thikr'] ?? false,
      date: DateTime.parse(map['date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fajrPrayer': fajrPrayer.toMap(),
      'dhuhrPrayer': dhuhrPrayer.toMap(),
      'asrPrayer': asrPrayer.toMap(),
      'maghribPrayer': maghribPrayer.toMap(),
      'ishaPrayer': ishaPrayer.toMap(),
      'suhoor': suhoor,
      'tahajjud': tahajjud,
      'qiyam': qiyam,
      'quran': quran,
      'thikr': thikr,
      'date': date.toIso8601String(),
    };
  }
}
