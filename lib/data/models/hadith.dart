class Hadith {
  final int? id;
  final String content;
  final String? source;
  final String? title;

  Hadith({
    this.id,
    required this.content,
    this.source,
    this.title,
  }) {
    if (content.isEmpty) {
      throw ArgumentError('محتوى الحديث لا يمكن أن يكون فارغاً');
    }
  }

  factory Hadith.fromMap(Map<String, dynamic> map) {
    if (map['content'] == null) {
      throw ArgumentError('البيانات غير كاملة: يجب توفير محتوى الحديث');
    }

    return Hadith(
      id: map['id'],
      content: map['content'],
      title: map['title'],
      source: map['source'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'title': title,
      'source': source,
    };
  }

  Hadith copyWith({
    int? id,
    String? content,
    String? narrator,
    String? source,
    String? title,
  }) {
    return Hadith(
      id: id ?? this.id,
      content: content ?? this.content,
      source: source ?? this.source,
      title: title ?? this.title,
    );
  }

  @override
  String toString() {
    return 'Hadith(id: $id, title: $title, content: $content, source: $source)';
  }
}
