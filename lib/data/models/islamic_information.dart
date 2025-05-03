class IslamicInformation {
  final int? id;
  final String title;
  final String content;
  final String? category;


  IslamicInformation({
    this.id,
    required this.title,
    required this.content,
    this.category,
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

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,

    };
  }

  /// إنشاء نسخة معدلة من هذا النموذج
  IslamicInformation copyWith({
    int? id,
    String? title,
    String? content,
    String? category,

  }) {
    return IslamicInformation(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,

    );
  }

  @override
  String toString() {
    return 'IslamicInformation(id: $id, title: $title, content: $content, category: $category)';
  }
}
