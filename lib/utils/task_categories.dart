import 'package:flutter/material.dart';

enum TaskCategories {
  education,
  health,
  shopping,
  travel,
  home,
  social,
  personal,
  work,
  sport,
}

extension TaskCategoriesExtension on TaskCategories {
  IconData get icon {
    switch (this) {
      case TaskCategories.education:
        return Icons.school;
      case TaskCategories.health:
        return Icons.favorite;
      case TaskCategories.shopping:
        return Icons.shopping_bag;
      case TaskCategories.travel:
        return Icons.flight;
      case TaskCategories.home:
        return Icons.home;
      case TaskCategories.social:
        return Icons.people;
      case TaskCategories.personal:
        return Icons.person;
      case TaskCategories.work:
        return Icons.work;
      case TaskCategories.sport:
        return Icons.sports_gymnastics;
    }
  }

  static TaskCategories fromString(String category) {
    switch (category) {
      case 'education':
        return TaskCategories.education;
      case 'health':
        return TaskCategories.health;
      case 'shopping':
        return TaskCategories.shopping;
      case 'travel':
        return TaskCategories.travel;
      case 'home':
        return TaskCategories.home;
      case 'social':
        return TaskCategories.social;
      case 'personal':
        return TaskCategories.personal;
      case 'work':
        return TaskCategories.work;
      case 'sport':
        return TaskCategories.sport;
      default:
        return TaskCategories.home;
    }
  }

  Color get color {
    switch (this) {
      case TaskCategories.education:
        return Colors.blue;
      case TaskCategories.health:
        return Colors.red;
      case TaskCategories.shopping:
        return Colors.orange;
      case TaskCategories.travel:
        return Colors.purple;
      case TaskCategories.home:
        return Colors.grey;
      case TaskCategories.social:
        return Colors.yellow;
      case TaskCategories.personal:
        return Colors.lightBlue;
      case TaskCategories.work:
        return Colors.green;
      case TaskCategories.sport:
        return Colors.deepOrange;
    }
  }

  static TaskCategories stringToCategory(String name) {
    try {
      return TaskCategories.values.firstWhere(
        (category) => category.name == name,
      );
    } catch (e) {
      return TaskCategories
          .home; // Retourne une valeur par défaut en cas d'erreur
    }
  }
}
