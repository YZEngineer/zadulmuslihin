class Athkar {
  final int? id;
  final String content;
  final String? category;
  final int count;
  final String? fadl;
  final String? source;

  Athkar({
    this.id,
    required this.content,
    this.category,
    this.count = 1,
    this.fadl,
    this.source,
  }) {
    if (content.isEmpty) {
      throw ArgumentError('محتوى الذكر لا يمكن أن يكون فارغاً');
    }
    if (count < 1) {
      throw ArgumentError('عدد مرات الذكر يجب أن يكون على الأقل 1');
    }
  }

  factory Athkar.fromMap(Map<String, dynamic> map) {
    if (map['content'] == null) {
      throw ArgumentError('البيانات غير كاملة: يجب توفير محتوى الذكر');
    }

    return Athkar(
      id: map['id'],
      content: map['content'],
      category: map['category'],
      count: map['count'] ?? 1,
      fadl: map['fadl'],
      source: map['source'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'category': category,
      'count': count,
      'fadl': fadl,
      'source': source,
    };
  }

  Athkar copyWith({
    int? id,
    String? content,
    String? category,
    int? count,
    String? fadl,
    String? source,
  }) {
    return Athkar(
      id: id ?? this.id,
      content: content ?? this.content,
      category: category ?? this.category,
      count: count ?? this.count,
      fadl: fadl ?? this.fadl,
      source: source ?? this.source,
    );
  }

  @override
  String toString() {
    return 'Athkar(id: $id, content: ${content.substring(0, content.length > 30 ? 30 : content.length)}..., '
        'category: $category, count: $count, source: $source)';
  }
}
