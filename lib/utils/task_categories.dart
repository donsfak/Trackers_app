import 'package:flutter/material.dart';

enum TaskCategories {
  education(Icons.school, Colors.blue),
  health(Icons.favorite, Colors.red),
  shopping(Icons.shopping_bag, Colors.orange),
  traverl(Icons.flight, Colors.purple),
  home(Icons.home, Colors.grey),
  social(Icons.people, Colors.yellow),
  personal(Icons.person, Colors.lightBlue),
  work(Icons.work, Colors.green),
  sport(Icons.sports_gymnastics, Colors.deepOrange),
  ;

  static TaskCategories stringToCategory(String name) {
    try {
      return TaskCategories.values
          .firstWhere((category) => category.name == name);
    } catch (e) {
      return TaskCategories.home;
    }
  }

  final IconData icon;
  final Color color;
  const TaskCategories(this.icon, this.color);
}
