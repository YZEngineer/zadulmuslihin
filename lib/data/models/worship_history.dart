

class WorshipHistory {
  final int id;
  final int date;
  final int totalpray;
  final bool tahajjud;
  final bool qiyam;
  final bool quran;
  final bool thikr;

  WorshipHistory({
    required this.id,
    required this.date,
    required this.totalpray,
    required this.tahajjud,
    required this.qiyam,
    required this.quran,
    required this.thikr,
  });

  factory WorshipHistory.fromJson(Map<String, dynamic> json) {
    return WorshipHistory(
      id: json['id'],
      date: json['date'],
      totalpray: json['totalpray'],
      tahajjud: json['tahajjud'],
      qiyam: json['qiyam'],
      quran: json['quran'],
      thikr: json['thikr'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'totalpray': totalpray,
      'tahajjud': tahajjud, 
      'qiyam': qiyam,
      'quran': quran,
      'thikr': thikr,
    };
  }
}




