import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'task.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;
  DatabaseHelper._createInstance();

  String taskTable = 'task_table';

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'tasks.db';

    var tasksDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return tasksDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE table $taskTable (id INTEGER PRIMARY KEY AUTOINCREMENT, task TEXT, checked INTEGER, date TEXT)');
  }

  Future<List<Map<String, dynamic>>> getTaskMapList() async {
    Database db = await this.database;
    return await db.query(taskTable, orderBy: 'date ASC');
  }

  Future<int> insertTask(Task task) async {
    Database db = await this.database;
    return await db.insert(taskTable, task.toMap());
  }

  Future<int> deleteTask(int id) async {
    var db = await this.database;
    return await db.delete(taskTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> changeCheckTask(int id, int state) async {
    var db = await this.database;
    Map<String, dynamic> update = {'checked': state};
    return await db.update(taskTable, update, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getTaskDates() async {
    var db = await this.database;
    return await db.rawQuery("SELECT DISTINCT date FROM task_table");
  }

  Future<List<Map<String, dynamic>>> getTaskOnDate(String date) async {
    var db = await this.database;
    return await db
        .rawQuery("SELECT DISTINCT date FROM task_table WHERE date='$date'");
  }

  void clearTable() async {
    var db = await this.database;
    await db.rawQuery('DELETE FROM $taskTable');
  }
}
