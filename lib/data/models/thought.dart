class Thought {
  final int? id;
  final String title;
  final String content;
  final int category; // 0: دنيوي، 1: أخروي، 2: كلاهما
  final DateTime date; // اليوم مطلوب

  Thought({
    this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.date,
  });

  factory Thought.fromJson(Map<String, dynamic> json) {
    return Thought(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'date': date,
    };
  }

  Map<String, dynamic> toMap() => toJson();
}
