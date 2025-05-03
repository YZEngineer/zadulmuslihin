import 'package:intl/intl.dart';

class DailyTask {
  final int? id;
  final String title;
  final bool isCompleted;
  final bool workOn;
  final int? category;

  DailyTask({
    this.id,
    required this.title,
    this.isCompleted = false,
    this.category,
    this.workOn = false,
  }) {
    if (title.isEmpty) {
      throw ArgumentError('عنوان المهمة لا يمكن أن يكون فارغاً');
    }
  }

  factory DailyTask.fromMap(Map<String, dynamic> map) {
    if (map['title'] == null) {
      throw ArgumentError('البيانات غير كاملة: يجب توفير عنوان المهمة');
    }

   

   

    return DailyTask(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'] == 1,
      category: map['category'],
      workOn: map['workOn'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
      'category': category,
      'workOn': workOn,
    };
  }

  DailyTask copyWith({
    int? id,
    String? title,
    bool? isCompleted,
    String? category,
    bool? workOn,
  }) {
    return DailyTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category as int?,
      workOn: workOn ?? this.workOn,
    );
  }




  @override
  String toString() {
    return 'DailyTask(id: $id, title: $title, isCompleted: $isCompleted, '
        'category: $category, workOn: $workOn)';
  }
}
