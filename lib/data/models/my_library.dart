class MyLibrary {
  final int? id;
  final String? title;
  final String content;
  final String? source;
  final String tabName;
  final String? links;
  final String type; // نوع المحتوى: ذكر، آية، حديث
  final String? category;
  MyLibrary({
    this.id,
    this.title,
    required this.content,
    this.source,
    required this.tabName,
    this.links,
    required this.type,
    this.category,
  });

  factory MyLibrary.fromJson(Map<String, dynamic> json) {
    return MyLibrary(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      source: json['source'],
      tabName: json['tabName'],
      links: json['links'],
      type: json['type'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'source': source,
      'tabName': tabName,
      'links': links,
      'type': type,
      'category': category,
    };
  }

  @override
  String toString() {
    return 'MyLibrary(id: $id, title: $title, content: $content, source: $source, tabName: $tabName, links: $links, type: $type, category: $category)';
  }
}
