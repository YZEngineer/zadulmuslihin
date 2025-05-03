class Prayer {
  final bool farz ;
  final bool sunnah ;
  final bool inMosque ;


  Prayer({
    required this.farz,
    required this.sunnah,
    required this.inMosque,
  });

  Prayer.fromMap(Map<String, dynamic> map) {
    farz = map['farz'];
    sunnah = map['sunnah'];
    inMosque = map['inMosque'];
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
  });

  factory DailyPrayer.fromMap(Map<String, dynamic> map) {
    return DailyPrayer(
      id: map['id'],
      fajrPrayer: map['fajrPrayer'],
      dhuhrPrayer: map['dhuhrPrayer'],
      asrPrayer: map['asrPrayer'],
      maghribPrayer: map['maghribPrayer'],
      ishaPrayer: map['ishaPrayer'],
      suhoor: map['suhoor'],
      tahajjud: map['tahajjud'],
      qiyam: map['qiyam'],
      quran: map['quran'],
      thikr: map['thikr'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'occasion': occasion,
      'arabic': arabic,
      'translation': translation,
      'source': source,
    };
  }
}
