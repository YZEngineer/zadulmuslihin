class DailyTask {
  final int? id;
  final String title;
  final int category; // عادات، أهداف، رياضة، أخرى
  final bool completed;
  final bool workOn; // يومي، أسبوعي، شهري، لا يتكرر

  DailyTask({
    this.id,
    required this.title,
    required this.category,
    this.completed = false,
    required this.workOn,
  }) {
    if (title.isEmpty) {
      throw ArgumentError(
          'البيانات غير كاملة: يجب توفير عنوان المهمة وتصنيف'); // ممكن حذفه لاحقا
    }
  }

  factory DailyTask.fromMap(Map<String, dynamic> map) {
    return DailyTask(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      completed: map['is_completed'] == 1 || map['completed'] == 1,
      workOn: map['is_on_working'] == 1 || map['workOn'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'is_completed': completed ? 1 : 0,
      'is_on_working': workOn ? 1 : 0,
    };
  }

  DailyTask copyWith({
    int? id,
    String? title,
    int? category,
    bool? completed,
    bool? workOn,
    DateTime? date,
    DateTime? dueDate,
  }) {
    return DailyTask(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      completed: completed ?? this.completed,
      workOn: workOn ?? this.workOn,
    );
  }

  @override
  String toString() {
    return 'DailyTask(id: $id, title: $title, isCompleted: $completed, '
        'category: $category, workOn: $workOn)';
  }
}
