class DailyMessage {
  final int? id;
  final String content;
  final String title;
  final String category; // حكمة، آية، حديث، دعاء، اقتباس
  final DateTime date; // تاريخ الرسالة
  final String? source; // مصدر الرسالة
  DailyMessage({
    this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.date,
    this.source,
  });

  factory DailyMessage.fromMap(Map<String, dynamic> map) {
    return DailyMessage(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      source: map['source'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'date': date.toIso8601String(),
      'source': source,
    };
  }

  DailyMessage copyWith({
    int? id,
    String? content,
    String? category,
    DateTime? date,
    String? source,
  }) {
    return DailyMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      title: title ?? this.title,
      category: category ?? this.category,
      date: date ?? this.date,
      source: source ?? this.source,
    );
  }

  @override
  String toString() {
    return 'DailyMessage(id: $id, content: $content, title: $title, category: $category, date: $date, source: $source)';
  }
}
