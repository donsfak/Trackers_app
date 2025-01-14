import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:trackers_app/config/routes/routes.dart';
import 'package:trackers_app/screens/heatmap_screen.dart';
import 'package:trackers_app/screens/screens.dart';

final navigationKey = GlobalKey<NavigatorState>();
late final DateTime startdate;
final appRoutes = [
  GoRoute(
      path: RouteLocation.home,
      parentNavigatorKey: navigationKey,
      builder: HomeScreen.builder),
  GoRoute(
      path: RouteLocation.createTask,
      parentNavigatorKey: navigationKey,
      builder: CreateTaskScreen.builder),
  GoRoute(
    path: RouteLocation.heatMap,
    parentNavigatorKey: navigationKey,
    builder: (HeatmapScreen.builder),
  ),
];
