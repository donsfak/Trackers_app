// lib/data/datasource/task_datasource.dart

// ignore_for_file: avoid_print, unused_element, unused_catch_stack

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:trackers_app/data/datasource/datasource_exception.dart';
// Importer le modèle Task MIS À JOUR (avec DateTime)
import 'package:trackers_app/data/models/task.dart';
import 'package:trackers_app/utils/db_keys.dart';
// Importer TaskKeys si nécessaire (utilisé implicitement par Task.fromJson/toJson)
// import 'package:trackers_app/utils/task_keys.dart';

// --- Formats de Date ---
// Format standard pour stockage/parsing interne (ISO 8601)
final DateFormat _dbDateFormat = DateFormat('yyyy-MM-dd');
// Ancien format stocké, nécessaire UNIQUEMENT pour la migration
// !! Assurez-vous que ce format correspond EXACTEMENT à ce qui était dans la BDD !!
final DateFormat _oldDateFormatForMigration = DateFormat('MMM dd, yyyy',
    'en_US'); // J'ai retiré 'Autoriteit Persoonsgegevens', était-ce correct ? Ajustez si besoin.
// ----------------------

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
      if (kDebugMode) {
        print("Database path: $path");
      }

      return await openDatabase(
        path,
        // --- MODIFICATION VERSION ET AJOUT onUpgrade ---
        version: 2, // Incrémenter la version pour déclencher onUpgrade
        onCreate: _onCreate,
        onUpgrade: _onUpgrade, // Ajouter la fonction de migration
        // --- FIN MODIFICATION ---
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("CRITICAL DB INIT ERROR: $e\n$stackTrace");
      }
      throw DataSourceException(
          "Impossible d'initialiser la base de données.", e);
    }
  }

  // Appelée seulement si la BDD n'existe pas du tout (version 1 ou 2)
  Future<void> _onCreate(Database db, int version) async {
    if (kDebugMode) {
      print("Creating database version $version...");
    }
    await db.execute('''
      CREATE TABLE ${DBKeys.dbTable}(
        ${DBKeys.idColumn} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DBKeys.titleColumn} TEXT,
        ${DBKeys.noteColumn} TEXT,
        ${DBKeys.timeColumn} TEXT,
        ${DBKeys.dateColumn} TEXT, /* Sera stocké comme YYYY-MM-DD */
        ${DBKeys.categoryColumn} TEXT,
        ${DBKeys.isCompletedColumn} INTEGER
      )
    ''');
    if (kDebugMode) {
      print("Database table ${DBKeys.dbTable} created.");
    }
    // Pas besoin de migration ici car la table vient d'être créée avec la bonne structure.
  }

  // --- AJOUT DE LA FONCTION onUpgrade ---
  // Appelée si la version de la BDD existante est < à la version demandée (ici, si oldVersion=1 et newVersion=2)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (kDebugMode) {
      print("Upgrading database from version $oldVersion to $newVersion...");
    }
    if (oldVersion < 2) {
      // Logique de migration de v1 à v2: Changer format de date
      if (kDebugMode) {
        print(
            "Applying migration v1 -> v2: Converting date format (MMM dd, yyyy -> yyyy-MM-dd)...");
      }
      await db.transaction((txn) async {
        Stopwatch stopwatch = Stopwatch()..start(); // Mesurer le temps
        int migratedCount = 0;
        int errorCount = 0;
        try {
          final List<Map<String, dynamic>> oldTasks = await txn.query(
            DBKeys.dbTable,
            columns: [DBKeys.idColumn, DBKeys.dateColumn],
          );
          if (kDebugMode) {
            print(
                "Found ${oldTasks.length} tasks to potentially migrate date format.");
          }

          for (var taskMap in oldTasks) {
            final id = taskMap[DBKeys.idColumn] as int?;
            final oldDateString = taskMap[DBKeys.dateColumn] as String?;

            if (id != null && oldDateString != null) {
              try {
                // Parse l'ancien format
                final dateTime = _oldDateFormatForMigration.parseStrict(
                    oldDateString); // Utiliser parseStrict pour être sûr du format
                // Formate vers le nouveau format
                final newDateString = _dbDateFormat.format(dateTime);

                // Mettre à jour la ligne
                int count = await txn.update(
                  DBKeys.dbTable,
                  {DBKeys.dateColumn: newDateString},
                  where: '${DBKeys.idColumn} = ?',
                  whereArgs: [id],
                );
                if (kDebugMode && count > 0) {
                  // print("Migrated task ID $id: '$oldDateString' -> '$newDateString'"); // Moins verbeux
                  migratedCount++;
                } else if (count == 0) {
                  if (kDebugMode) {
                    print(
                        "Warning: No rows updated for task ID $id during migration.");
                  }
                }
              } catch (e) {
                errorCount++;
                // Erreur lors du parsing/formatage pour CETTE tâche, on log et on continue
                if (kDebugMode) {
                  print(
                      "!!! Error migrating date for task ID $id ('$oldDateString'): $e. Skipping this task.");
                }
              }
            } else {
              if (kDebugMode) {
                print(
                    "Skipping migration for row with null id or date: $taskMap");
              }
              errorCount++;
            }
          }
          stopwatch.stop();
          if (kDebugMode) {
            print(
                "Date format migration v1 -> v2 completed in ${stopwatch.elapsedMilliseconds}ms. Migrated: $migratedCount, Errors/Skipped: $errorCount");
          }
        } catch (e, stackTrace) {
          stopwatch.stop();
          if (kDebugMode) {
            print(
                "Error during database migration transaction v1 -> v2: $e\n$stackTrace");
          }
          throw Exception("Database migration v1 -> v2 failed: $e");
        }
      });
    }
    // Ajouter d'autres `if (oldVersion < X)` ici pour des migrations futures si nécessaire
  }
  // --- FIN AJOUT onUpgrade ---

  // Les méthodes suivantes supposent que le modèle Task (avec date: DateTime)
  // gère correctement la conversion dans toJson et fromJson

  Future<int> addTask(Task task) async {
    try {
      final db = await database;
      final taskJson =
          task.toJson(); // Utilise Task.toJson qui formate date en YYYY-MM-DD
      if (kDebugMode) {
        print("Saving task with data: $taskJson");
      }
      return await db.insert(DBKeys.dbTable, taskJson,
          conflictAlgorithm: ConflictAlgorithm.replace);
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
      final taskJson =
          task.toJson(); // Utilise Task.toJson qui formate date en YYYY-MM-DD
      if (kDebugMode) {
        print("Updating task ID ${task.id} with data: $taskJson");
      }
      return await db.update(DBKeys.dbTable, taskJson,
          where: '${DBKeys.idColumn} = ?', whereArgs: [task.id]);
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
      return await db.delete(DBKeys.dbTable,
          where: '${DBKeys.idColumn} = ?', whereArgs: [task.id]);
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
          orderBy: '${DBKeys.dateColumn} DESC, ${DBKeys.timeColumn} DESC');
      if (kDebugMode) {
        print('Données brutes lues pour getAllTasks: $data');
      }
      // Task.fromJson doit maintenant parser la string YYYY-MM-DD en DateTime
      return List.generate(data.length, (index) => Task.fromJson(data[index]));
    } on DatabaseException catch (e, stackTrace) {
      if (kDebugMode) {
        print("DB Error getAllTasks: $e\n$stackTrace");
      }
      throw DataSourceException(
          "Erreur lors de la récupération des tâches.", e);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Unexpected Error getAllTasks (fromJson?): $e\n$stackTrace");
      }
      throw DataSourceException("Erreur récupération/conversion tâches.", e);
    }
  }

  Future<Map<DateTime, int>> getTasksCountByDate() async {
    // Cette méthode utilise maintenant date() SQL et DateTime.parse qui fonctionnent avec YYYY-MM-DD
    try {
      final db = await database;
      final result = await db.rawQuery('''
        SELECT date(${DBKeys.dateColumn}) AS date_group, COUNT(*) AS count
        FROM ${DBKeys.dbTable}
        WHERE ${DBKeys.isCompletedColumn} = 1
        GROUP BY date_group
      '''); // Utilise date() SQL

      final Map<DateTime, int> heatmapData = {};
      if (kDebugMode) {
        print("Heatmap Query Result Count: ${result.length}");
      }
      for (var row in result) {
        try {
          final dateString = row['date_group'] as String?;
          final count = row['count'] as int?;
          if (dateString != null && count != null) {
            if (kDebugMode) {
              print("Heatmap Parsing: date='$dateString', count=$count");
            }
            // DateTime.parse fonctionne avec YYYY-MM-DD
            final dateTime = DateTime.parse(dateString);
            heatmapData[dateTime] = count;
          } else {
            if (kDebugMode) {
              print("Heatmap Skipping row: date or count is null - $row");
            }
          }
        } catch (parseError, stackTrace) {
          if (kDebugMode) {
            print(
                "!!! Erreur parsing date heatmap: '${row['date_group']}' -> $parseError\n$stackTrace");
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
