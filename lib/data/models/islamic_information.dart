class IslamicInformation {
  final int? id;
  final String title;
  final String content;
  final String? category;
  final String? source;

  IslamicInformation({
    this.id,
    required this.title,
    required this.content,
    this.category,
    this.source,
  }) {
    if (title.isEmpty) {
      throw ArgumentError('عنوان المعلومة الإسلامية لا يمكن أن يكون فارغاً');
    }
    if (content.isEmpty) {
      throw ArgumentError('محتوى المعلومة الإسلامية لا يمكن أن يكون فارغاً');
    }
  }

  factory IslamicInformation.fromMap(Map<String, dynamic> map) {
    if (map['title'] == null || map['content'] == null) {
      throw ArgumentError('البيانات غير كاملة: يجب توفير العنوان والمحتوى');
    }

    return IslamicInformation(
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

  /// إنشاء نسخة معدلة من هذا النموذج
  IslamicInformation copyWith({
    int? id,
    String? title,
    String? content,
    String? category,
    String? source,
  }) {
    return IslamicInformation(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      source: source ?? this.source,
    );
  }

  @override
  String toString() {
    return 'IslamicInformation(id: $id, title: $title, category: $category, source: $source)';
  }
}
