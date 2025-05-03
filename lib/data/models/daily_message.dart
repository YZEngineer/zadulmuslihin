class DailyMessage {
  final int id;
  final String title;
  final String content;
  final int category;
  final String source;

  DailyMessage({
    this.id = 0,
    required this.title,
    required this.content,
    required this.category,
    required this.source,
  });

  factory DailyMessage.fromMap(Map<String, dynamic> map) {
    return DailyMessage(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      category: map['category'],
      source: map['source'],
    );  
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'source': source,
    };
  }

  DailyMessage copyWith({
    int? id,
    String? title,
    String? content,
    int? category,
    String? source,
  }) {
    return DailyMessage(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      source: source ?? this.source,
    );
  }

  @override
  String toString() {
    return 'DailyMessage(id: $id, title: $title, content: $content, category: $category, source: $source)';
  }
}

