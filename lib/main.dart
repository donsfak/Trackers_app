import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackers_app/app/trackers_app.dart';

void main() {
  runApp(
    ProviderScope(
      child: TrackersApp(),
    ),
    //),
  );
}
