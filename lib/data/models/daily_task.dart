import 'package:intl/intl.dart';

class DailyTask {
  final int? id;
  final String title;
  final String? description;
  final bool isCompleted;
  final String? category;
  final DateTime? dueDate;
  final DateTime createdAt;

  DailyTask({
    this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.category,
    this.dueDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now() {
    if (title.isEmpty) {
      throw ArgumentError('عنوان المهمة لا يمكن أن يكون فارغاً');
    }
  }

  factory DailyTask.fromMap(Map<String, dynamic> map) {
    if (map['title'] == null) {
      throw ArgumentError('البيانات غير كاملة: يجب توفير عنوان المهمة');
    }

    DateTime? dueDate;
    if (map['due_date'] != null) {
      dueDate = map['due_date'] is String 
          ? DateTime.parse(map['due_date'])
          : map['due_date'];
    }

    DateTime createdAt = DateTime.now();
    if (map['created_at'] != null) {
      createdAt = map['created_at'] is String 
          ? DateTime.parse(map['created_at'])
          : map['created_at'];
    }

    return DailyTask(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1,
      category: map['category'],
      dueDate: dueDate,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'category': category,
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  DailyTask copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    String? category,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    return DailyTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isOverdue {
    if (dueDate == null) return false;
    return !isCompleted && dueDate!.isBefore(DateTime.now());
  }

  String get formattedDueDate {
    if (dueDate == null) return '';
    return DateFormat('yyyy-MM-dd').format(dueDate!);
  }

  @override
  String toString() {
    return 'DailyTask(id: $id, title: $title, isCompleted: $isCompleted, '
        'category: $category, dueDate: ${dueDate?.toIso8601String()})';
  }
}
