import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:trackers_app/config/routes/routes.dart';
import 'package:trackers_app/screens/heatmap_screen.dart';
import 'package:trackers_app/screens/modify_task_screen.dart';
import 'package:trackers_app/screens/screens.dart';
import 'package:trackers_app/screens/ai_chat_screen.dart';

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
  GoRoute(
    path: RouteLocation.modifyTask,
    parentNavigatorKey: navigationKey,
    builder: (ModifyTaskScreen.builder),
  ),
  GoRoute(
    path: RouteLocation.aiChat,
    parentNavigatorKey: navigationKey,
    builder: AiChatScreen.builder,
  ),
];
