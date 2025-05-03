  
class MyLibrary {
  final int id;
  final String title;
  final String content;
  final String? source;
  final int tabName;

  MyLibrary({
    required this.id,
    required this.title,
    required this.content,
    this.source,
    required this.tabName,
  });

  factory MyLibrary.fromJson(Map<String, dynamic> json) {
    return MyLibrary(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      source: json['source'],
      tabName: json['tab_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'source': source,
      'tab_name': tabName,
    };
  }

  @override
  String toString() {
    return 'MyLibrary(id: $id, title: $title, content: $content, source: $source, tabName: $tabName)';
  }

 
}



