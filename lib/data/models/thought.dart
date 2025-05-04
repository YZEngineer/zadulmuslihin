  
 
class Thought {
  final int? id;
  final String title;
  final String content;
  final DateTime date;
  final int category; // 0: دنيوي، 1: أخروي، 2: كلاهما
  final bool isArchived;
  final int day;

  Thought({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.category,
    required this.isArchived,
    required this.day,
  });

  factory Thought.fromJson(Map<String, dynamic> json) {
    return Thought(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      date: json['date'],
      category: json['category'],
      isArchived: json['is_archived'],
      day: json['day'],
    );
  }

  Map<String, dynamic> toJson() {
    return {  
      'id': id,
      'title': title,
      'content': content,
      'date': date,
      'category': category,
      'is_archived': isArchived,  
      'day': day,
    };
  }

}


