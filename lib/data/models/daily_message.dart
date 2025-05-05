class DailyMessage {
  final int? id;
  final String title;
  final String content;
  final int category;
  final String source;
  final DateTime date;

  DailyMessage({
    this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.source,
    required this.date,
  });

  factory DailyMessage.fromMap(Map<String, dynamic> map) {
    return DailyMessage(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      category: map['category'],
      source: map['source'],
      date: map['date'] is String ? DateTime.parse(map['date']) : map['date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'source': source,
      'date': date.toIso8601String(),
    };
  }

  DailyMessage copyWith({
    int? id,
    String? title,
    String? content,
    int? category,
    String? source,
    DateTime? date,
  }) {
    return DailyMessage(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      source: source ?? this.source,
      date: date ?? this.date,
    );
  }

  @override
  String toString() {
    return 'DailyMessage(id: $id, title: $title, content: $content, category: $category, source: $source, date: $date)';
  }
}
