import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trackers_app/config/routes/routes.dart';

final routesProviders = Provider<GoRouter>((ref) {
  return GoRouter(
      initialLocation: RouteLocation.home,
      navigatorKey: navigationKey,
      routes: appRoutes);
});
