import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackers_app/app/trackers_app.dart';

import 'package:trackers_app/utils/utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure binding is first
  await dotenv.load(fileName: ".env");
  await AppNotifications.init();

  runApp(
    ProviderScope(
      child: TrackersApp(),
    ),
    //),
  );
}
