// Utiliser un format standard ISO 8601 (YYYY-MM-DD) pour le stockage et parsing interne
// ignore_for_file: unused_element

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:trackers_app/data/datasource/datasource_exception.dart';
import 'package:trackers_app/data/models/task.dart';
import 'package:trackers_app/utils/db_keys.dart';

final DateFormat _dbDateFormat = DateFormat('yyyy-MM-dd');

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
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, DBKeys.dbName);
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("CRITICAL DB INIT ERROR: $e\n$stackTrace");
      }
      throw DataSourceException(
          "Impossible d'initialiser la base de données.", e);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${DBKeys.dbTable}(
      ${DBKeys.idColumn} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DBKeys.titleColumn} TEXT,
      ${DBKeys.noteColumn} TEXT,
      ${DBKeys.timeColumn} TEXT,
      ${DBKeys.dateColumn} TEXT, /* Stocké comme YYYY-MM-DD */
      ${DBKeys.categoryColumn} TEXT,
      ${DBKeys.isCompletedColumn} INTEGER
      )
    ''');
  }

  Future<int> addTask(Task task) async {
    try {
      final db = await database;
      final taskJson = task.toJson();
      // Assurez-vous que la date dans toJson est bien une String YYYY-MM-DD
      // Si task.date est un DateTime, il faut le formater ici
      // Si task.date est déjà une String dans le bon format, c'est ok.
      // Supposons que Task.toJson gère cela correctement ou que Task.date est déjà String.
      // Pour être sûr, on peut forcer le format:
      // taskJson[TaskKeys.date] = _dbDateFormat.format(DateTime.parse(task.date)); // Si task.date est une string parsable
      // taskJson[TaskKeys.date] = _dbDateFormat.format(task.date); // Si task.date est un DateTime

      // Vérifions la sortie de toJson dans le modèle Task pour être sûr...
      // D'après le modèle Task, task.date EST une String. Assumons qu'elle est au bon format.

      return await db.insert(
        DBKeys.dbTable,
        taskJson, // Utilise directement toJson qui retourne la date comme String
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } on DatabaseException catch (e, stackTrace) {
      if (kDebugMode) {
        print("DB Error addTask: $e\n$stackTrace");
      }
      throw DataSourceException("Erreur lors de l'ajout de la tâche.", e);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Unexpected Error addTask: $e\n$stackTrace");
      }
      throw DataSourceException("Erreur inattendue lors de l'ajout.", e);
    }
  }

  Future<int> updateTask(Task task) async {
    try {
      final db = await database;
      final taskJson = task.toJson();
      // Comme pour addTask, s'assurer que taskJson[TaskKeys.date] est String YYYY-MM-DD
      // taskJson[TaskKeys.date] = _dbDateFormat.format(DateTime.parse(task.date)); // Si task.date est String
      // taskJson[TaskKeys.date] = _dbDateFormat.format(task.date); // Si task.date est DateTime

      return await db.update(
        DBKeys.dbTable,
        taskJson, // Utilise toJson
        where: '${DBKeys.idColumn} = ?',
        whereArgs: [task.id],
      );
    } on DatabaseException catch (e, stackTrace) {
      if (kDebugMode) {
        print("DB Error updateTask: $e\n$stackTrace");
      }
      throw DataSourceException("Erreur lors de la mise à jour.", e);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Unexpected Error updateTask: $e\n$stackTrace");
      }
      throw DataSourceException("Erreur inattendue lors de la mise à jour.", e);
    }
  }

  Future<int> deleteTask(Task task) async {
    try {
      final db = await database;
      return await db.delete(
        DBKeys.dbTable,
        where: '${DBKeys.idColumn} = ?',
        whereArgs: [task.id],
      );
    } on DatabaseException catch (e, stackTrace) {
      if (kDebugMode) {
        print("DB Error deleteTask: $e\n$stackTrace");
      }
      throw DataSourceException("Erreur lors de la suppression.", e);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Unexpected Error deleteTask: $e\n$stackTrace");
      }
      throw DataSourceException("Erreur inattendue lors de la suppression.", e);
    }
  }

  Future<List<Task>> getAllTasks() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> data = await db.query(DBKeys.dbTable,
          orderBy:
              '${DBKeys.dateColumn} DESC, ${DBKeys.timeColumn} DESC' // Optionnel: trier
          );
      if (kDebugMode) {
        print('Données brutes lues pour getAllTasks: $data');
      }

      // --- CORRECTION ICI ---
      // Passer directement la map brute à Task.fromJson, car il attend une String pour la date.
      return List.generate(data.length, (index) => Task.fromJson(data[index]));
      // --- FIN CORRECTION ---
    } on DatabaseException catch (e, stackTrace) {
      if (kDebugMode) {
        print("DB Error getAllTasks: $e\n$stackTrace");
      }
      throw DataSourceException(
          "Erreur lors de la récupération des tâches.", e);
    } catch (e, stackTrace) {
      // Attraper aussi les erreurs potentielles de Task.fromJson (qui lance FormatException)
      if (kDebugMode) {
        print(
            "Unexpected Error getAllTasks (peut-être fromJson): $e\n$stackTrace");
      }
      throw DataSourceException(
          "Erreur inattendue lors de la récupération ou conversion des tâches.",
          e);
    }
  }

  Future<Map<DateTime, int>> getTasksCountByDate() async {
    try {
      final db = await database;
      // Utiliser date() pour grouper par jour YYYY-MM-DD
      final result = await db.rawQuery('''
        SELECT date(${DBKeys.dateColumn}) AS date_group, COUNT(*) AS count
        FROM ${DBKeys.dbTable}
        WHERE ${DBKeys.isCompletedColumn} = 1
        GROUP BY date_group
      ''');

      final Map<DateTime, int> heatmapData = {};
      for (var row in result) {
        try {
          final dateString = row['date_group'] as String?;
          if (dateString != null) {
            // Parser la date au format YYYY-MM-DD
            final dateTime = DateTime.parse(dateString);
            heatmapData[dateTime] = row['count'] as int;
          }
        } catch (parseError, stackTrace) {
          // Logguer l'erreur de parsing mais continuer si possible
          if (kDebugMode) {
            print(
                "Erreur parsing date heatmap: ${row['date_group']} -> $parseError\n$stackTrace");
          }
        }
      }
      if (kDebugMode) {
        print("Heatmap data générée: $heatmapData");
      }
      return heatmapData;
    } on DatabaseException catch (e, stackTrace) {
      if (kDebugMode) {
        print("DB Error getTasksCountByDate: $e\n$stackTrace");
      }
      throw DataSourceException("Erreur lors du comptage pour la heatmap.", e);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Unexpected Error getTasksCountByDate: $e\n$stackTrace");
      }
      throw DataSourceException("Erreur inattendue lors du comptage.", e);
    }
  }
}
