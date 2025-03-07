// ignore_for_file: avoid_print

import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:trackers_app/data/models/task.dart';
import 'package:trackers_app/utils/db_keys.dart';

final DateFormat dateFormat = DateFormat('MMM dd, yyyy');

class TaskDatasource {
  static final TaskDatasource _instace = TaskDatasource._();
  factory TaskDatasource() => _instace;

  TaskDatasource._() {
    _initDB();
  }

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DBKeys.dbName);
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${DBKeys.dbTable}(
      
      ${DBKeys.idColumn} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DBKeys.titleColumn} TEXT,
      ${DBKeys.noteColumn} TEXT,
      ${DBKeys.timeColumn} TEXT,
      ${DBKeys.dateColumn} TEXT,
      ${DBKeys.categoryColumn} TEXT,
      ${DBKeys.isCompletedColumn} INTEGER
      )
    ''');
  }

  Future<int> addTask(Task task) async {
    final db = await database;
    return db.transaction(
      (txn) async {
        return await txn.insert(
          DBKeys.dbTable,
          task.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      },
    );
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return db.transaction(
      (txn) async {
        return await txn.update(
          DBKeys.dbTable,
          task.toJson(),
          where: 'id = ?',
          whereArgs: [task.id],
        );
      },
    );
  }

  Future<int> deleteTask(Task task) async {
    final db = await database;
    return db.transaction(
      (txn) async {
        return await txn.delete(
          DBKeys.dbTable,
          where: 'id = ?',
          whereArgs: [task.id],
        );
      },
    );
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> data = await db.query(DBKeys.dbTable);
    print('Données brutes de la base de données: $data'); // Log pour déboguer
    return List.generate(data.length, (index) => Task.fromJson(data[index]));
  }

  Future<Map<DateTime, int>> getTasksCountByDate() async {
    final db = await database;

    // Exécuter une requête SQL pour compter les tâches terminées par date
    final result = await db.rawQuery('''
      SELECT ${DBKeys.dateColumn} AS date, COUNT(*) AS count
      FROM ${DBKeys.dbTable}
      WHERE ${DBKeys.isCompletedColumn} = 1
      GROUP BY ${DBKeys.dateColumn}
    ''');

    // Transformer les résultats en un Map<DateTime, int>
    return {
      for (var row in result)
        dateFormat.parse(row['date'] as String): row['count'] as int,
    };
  }
}
