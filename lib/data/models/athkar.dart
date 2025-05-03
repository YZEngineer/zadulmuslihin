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
  });

  factory Athkar.fromMap(Map<String, dynamic> map) {
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
}
