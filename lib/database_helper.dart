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
  String dailyTaskTable = 'daily_table';
  String historyTable = "history_table";

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

  // Get Singleton instance of Database
  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'tasks.db';
    var tasksDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return tasksDatabase;
  }

  // Create tables of database
  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE table $taskTable (id INTEGER PRIMARY KEY AUTOINCREMENT, task TEXT, checked INTEGER, date TEXT)');
    await db.execute(
        'CREATE table $dailyTaskTable (id INTEGER PRIMARY KEY AUTOINCREMENT, task TEXT, checked INTEGER)');
    await db.execute(
        'CREATE table $historyTable (id INTEGER PRIMARY KEY AUTOINCREMENT, task TEXT, checked INTEGER, date TEXT)');
  }

  // Get a list of all general tasks
  Future<List<Map<String, dynamic>>> getTaskMapList() async {
    Database db = await this.database;
    return await db.query(taskTable);
  }

  // Get a list of all daily tasks
  Future<List<Map<String, dynamic>>> getDailyTaskMapList() async {
    Database db = await this.database;
    return await db.query(dailyTaskTable);
  }

  // Get a list of all ended tasks
  Future<List<Map<String, dynamic>>> getHistoryMapList() async {
    Database db = await this.database;
    return await db.query(historyTable);
  }

  // Insert new general task
  Future<int> insertTask(Task task) async {
    Database db = await this.database;
    return await db.insert(taskTable, task.toMap());
  }

  // Insert new daily task
  Future<int> insertDailyTask(String task, int checked) async {
    Database db = await this.database;
    return await db.insert(dailyTaskTable, {'task': task, 'checked': checked});
  }

  // Insert new history task
  Future<int> insertHistoryTask(Map<String, dynamic> task) async {
    Database db = await this.database;
    return await db.insert(historyTable, task);
  }

  // Delete general task
  Future<int> deleteTask(int id) async {
    var db = await this.database;
    return await db.delete(taskTable, where: 'id = ?', whereArgs: [id]);
  }

  // Delete daily task
  Future<int> deleteDailyTask(int id) async {
    var db = await this.database;
    return await db.delete(dailyTaskTable, where: 'id = ?', whereArgs: [id]);
  }

  // Delete history task
  Future<int> deleteHistoryTask(int id) async {
    var db = await this.database;
    return await db.delete(historyTable, where: 'id = ?', whereArgs: [id]);
  }

  // Change check state of checkbox of daily task
  Future<int> changeCheckTask(int id, int state) async {
    var db = await this.database;
    Map<String, dynamic> update = {'checked': state};
    return await db.update(taskTable, update, where: 'id = ?', whereArgs: [id]);
  }

  // Change check state of checkbox of daily task
  Future<int> changeCheckDailyTask(int id, int state) async {
    var db = await this.database;
    Map<String, dynamic> update = {'checked': state};
    return await db
        .update(dailyTaskTable, update, where: 'id = ?', whereArgs: [id]);
  }

  // Reset daily tasks to unchecked
  Future<int> resetDailyTasks() async {
    var db = await this.database;
    Map<String, dynamic> update = {'checked': 0};
    return await db.update(dailyTaskTable, update);
  }

  // Get a list of dates that contain tasks
  Future<List<Map<String, dynamic>>> getTaskDates(String table) async {
    var db = await this.database;
    return await db.rawQuery("SELECT DISTINCT date FROM $table");
  }

  // Get a list of tasks on a given date
  Future<List<Map<String, dynamic>>> getTaskOnDate(
      String date, String table) async {
    var db = await this.database;
    return await db
        .rawQuery("SELECT DISTINCT date FROM $table WHERE date='$date'");
  }

  // Empty given table
  void clearTable(String table) async {
    var db = await this.database;
    await db.rawQuery('DELETE FROM $table');
  }

  // Delete the database
  void deleteDB() {
    var databasesPath = getDatabasesPath();
    databasesPath.then((dbpath) {
      String path = dbpath + 'tasks.db';
      var x = deleteDatabase(path);
      x.then((res) {});
    });
  }
}
