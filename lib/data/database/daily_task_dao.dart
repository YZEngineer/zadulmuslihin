import 'package:sqflite/sqflite.dart';
import '../models/daily_task.dart';
import 'database_helper.dart';

class DailyTaskDao {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(DailyTask task) async {
    Database db = await dbHelper.database;
    return await db.insert('daily_tasks', task.toMap());
  }

  Future<List<DailyTask>> getAllTasks() async {
    Database db = await dbHelper.database;
    var tasks = await db.query('daily_tasks', orderBy: 'date, time');

    return tasks.map((task) => DailyTask.fromMap(task)).toList();
  }

  Future<List<DailyTask>> getTasksByDate(String date) async {
    Database db = await dbHelper.database;
    var tasks = await db.query('daily_tasks',
        where: 'date = ?', whereArgs: [date], orderBy: 'time');

    return tasks.map((task) => DailyTask.fromMap(task)).toList();
  }

  Future<int> update(DailyTask task) async {
    Database db = await dbHelper.database;
    return await db.update('daily_tasks', task.toMap(),
        where: 'id = ?', whereArgs: [task.id]);
  }

  Future<int> delete(int id) async {
    Database db = await dbHelper.database;
    return await db.delete('daily_tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> toggleTaskCompletion(int id, bool isCompleted) async {
    Database db = await dbHelper.database;
    return await db.update('daily_tasks', {'isCompleted': isCompleted ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }
}
