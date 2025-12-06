// lib/data/models/task.dart

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart'; // Pour @immutable
import 'package:intl/intl.dart'; // Importer intl pour le formatage
import 'package:trackers_app/utils/utils.dart';

// Définir le format de date standard utilisé pour la BDD ici aussi
final DateFormat _dbDateFormat = DateFormat('yyyy-MM-dd');

@immutable // Bonne pratique
class Task extends Equatable {
  final int? id;
  final String title;
  final String note;
  final String time;
  // --- MODIFICATION TYPE : String -> DateTime ---
  final DateTime date;
  // --- FIN MODIFICATION ---
  final TaskCategories category;
  final bool isCompleted;

  const Task({
    this.id,
    required this.title,
    required this.note,
    required this.time,
    // --- MODIFICATION TYPE : required String -> required DateTime ---
    required this.date,
    // --- FIN MODIFICATION ---
    required this.category,
    required this.isCompleted,
  });

  @override
  List<Object?> get props {
    // props peut contenir des nullables
    return [
      id, // id est nullable
      title,
      note,
      time,
      date, // date est maintenant DateTime
      category, // Ajouter category pour une égalité complète
      isCompleted,
    ];
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      TaskKeys.id: id,
      TaskKeys.title: title,
      TaskKeys.note: note,
      TaskKeys.time: time,
      // --- MODIFICATION : Formater DateTime en String YYYY-MM-DD ---
      TaskKeys.date: _dbDateFormat.format(date),
      // --- FIN MODIFICATION ---
      TaskKeys.category: category.name,
      TaskKeys.isCompleted: isCompleted ? 1 : 0,
    };
  }

  factory Task.fromJson(Map<String, dynamic> map) {
    try {
      // --- MODIFICATION : Parser la String YYYY-MM-DD en DateTime ---
      DateTime parsedDate;
      final dateString = map[TaskKeys.date] as String?;
      if (dateString != null) {
        try {
          parsedDate = _dbDateFormat.parse(dateString);
        } catch (e) {
          if (kDebugMode) {
            print(
                "Erreur parsing date dans Task.fromJson: '$dateString' -> $e");
          }
          // Que faire en cas d'erreur ? Utiliser date actuelle ? Relancer ?
          // Utilisons DateTime.now() pour l'instant, mais à surveiller.
          parsedDate = DateTime.now();
        }
      } else {
        // Si la date est null dans la map (ne devrait pas arriver avec la BDD actuelle)
        if (kDebugMode) {
          print("Warning: Date null dans Task.fromJson pour map: $map");
        }
        parsedDate = DateTime.now(); // Date par défaut
      }
      // --- FIN MODIFICATION ---

      return Task(
        // Utiliser les clés de TaskKeys pour la robustesse
        id: map[TaskKeys.id] as int?, // Cast explicite en int?
        title: map[TaskKeys.title] as String? ??
            '', // Fournir valeur par défaut si null
        note: map[TaskKeys.note] as String? ?? '',
        time: map[TaskKeys.time] as String? ?? '',
        date: parsedDate, // Utiliser la date parsée
        category: TaskCategoriesExtension.stringToCategory(
            map[TaskKeys.category] as String? ??
                TaskCategories.home.name), // Gérer null et fournir défaut
        isCompleted: (map[TaskKeys.isCompleted] as int? ?? 0) ==
            1, // Gérer null et fournir défaut
      );
    } catch (e, stackTrace) {
      // Loguer l'erreur plus précisément
      if (kDebugMode) {
        print("Erreur dans Task.fromJson pour map $map: $e\n$stackTrace");
      }
      // Relancer une exception peut-être plus spécifique ou garder FormatException
      throw FormatException(
          'Erreur lors de la conversion des données en Task : $e');
    }
  }

  Task copyWith({
    int? id,
    String? title,
    String? note,
    String? time,
    // --- MODIFICATION TYPE : String? -> DateTime? ---
    DateTime? date,
    // --- FIN MODIFICATION ---
    TaskCategories? category,
    bool? isCompleted,
  }) {
    return Task(
      // Utiliser ?? pour gérer la non-modification de id si null est passé
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      time: time ?? this.time,
      date: date ?? this.date,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
