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
  });

  factory IslamicInformation.fromMap(Map<String, dynamic> map) {
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
}
