class DailyTask {
  final int? id;
  final String title;
  final String? description;
  final bool isCompleted;
  final String? category;


  DailyTask({
    this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.category,

  });

  factory DailyTask.fromMap(Map<String, dynamic> map) {
    return DailyTask(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1,
      category: map['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'category': category,
    };
  }

  DailyTask copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    String? category,
  }) {
    return DailyTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
    );
  }
}
