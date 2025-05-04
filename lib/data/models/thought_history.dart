class ThoughtHistory {
  final int? id;
  final int precentOf0;
  final int precentOf1;
  final int precentOf2;
  final int totalday;

  ThoughtHistory({
    this.id,
    required this.precentOf0,
    required this.precentOf1,
    required this.precentOf2,
    required this.totalday,
  });

  factory ThoughtHistory.fromJson(Map<String, dynamic> json) {
    return ThoughtHistory(
      id: json['id'],
      precentOf0: json['precentOf0'],
      precentOf1: json['precentOf1'],
      precentOf2: json['precentOf2'],
      totalday: json['totalday'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'precentOf0': precentOf0,
      'precentOf1': precentOf1,
      'precentOf2': precentOf2,
      'totalday': totalday,
    };
  }

  Map<String, dynamic> toMap() => toJson();
}
