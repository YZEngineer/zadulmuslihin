class Thought {
  final int? id;
  final String title;
  final String content;
  final int category; // 0: دنيوي، 1: أخروي، 2: كلاهما
  final int? day;

  Thought({
    this.id,
    required this.title,
    required this.content,
    required this.category,
    this.day,
  });

  factory Thought.fromJson(Map<String, dynamic> json) {
    return Thought(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      day: json['day'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'day': day,
    };
  }

  Map<String, dynamic> toMap() => toJson();
}
