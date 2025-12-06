import 'package:flutter/material.dart';

@immutable
class RouteLocation {
  const RouteLocation._();

  static String get home => '/home';
  static String get createTask => '/createTask';
  static String get heatMap => '/heatMap';
  static String get modifyTask => '/modifyTask';
  static String get aiChat => '/aiChat';
}
