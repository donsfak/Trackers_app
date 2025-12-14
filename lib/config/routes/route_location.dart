import 'package:flutter/material.dart';

@immutable
class RouteLocation {
  const RouteLocation._();

  static String get home => '/home';
  static String get createTask => '/createTask';
  static String get heatMap => '/heatMap';
  static const String modifyTask = '/modifyTask';
  static const String focus = '/focus';
  static String get aiChat => '/aiChat';
}
