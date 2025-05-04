class DailyTask {
  final int id;
  final String title; //عنوان المهمة
  final bool isCompleted; //مكتمل
  final bool workOn; //اعمل عليه
  final int category; // رياضة, عادات ,اهداف

  DailyTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.category,
    this.workOn = false,
  }) {
    if (title.isEmpty) {
      throw ArgumentError(
          'البيانات غير كاملة: يجب توفير عنوان المهمة وتصنيف'); // ممكن حذفه لاحقا
    }
  }

  factory DailyTask.fromMap(Map<String, dynamic> map) {
    if (map['title'] == null || map['category'] == null) {
      throw ArgumentError('البيانات غير كاملة: يجب توفير عنوان المهمة وتصنيف');
    }

    return DailyTask(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'] == 1,
      category: map['category'],
      workOn: map['workOn'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
      'category': category,
      'workOn': workOn ? 1 : 0,
    };
  }

  DailyTask copyWith({
    int? id,
    String? title,
    bool? isCompleted,
    int? category,
    bool? workOn,
  }) {
    return DailyTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      workOn: workOn ?? this.workOn,
    );
  }

  @override
  String toString() {
    return 'DailyTask(id: $id, title: $title, isCompleted: $isCompleted, '
        'category: $category, workOn: $workOn)';
  }
}
