// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trackers_app/config/routes/route_location.dart';

void showCustomBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.brightness_6, color: Colors.purple),
              title: const Text('System Theme'),
              onTap: () {
                Navigator.pop(context);
                print("System Theme sélectionné");
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.purple),
              title: const Text('Check Your Heatmap'),
              onTap: () {
                context.push(RouteLocation.heatMap);
                //Navigator.pop(context);
                print("Check Your Heatmap sélectionné");
              },
            ),
          ],
        ),
      );
    },
  );
}
