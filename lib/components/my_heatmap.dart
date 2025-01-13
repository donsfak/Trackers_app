import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:trackers_app/utils/extensions.dart';

class MyHeatmap extends StatelessWidget {
  final Map<DateTime, int> datasets;
  final DateTime startdate;
  //final DateEnd enddate;

  const MyHeatmap({
    super.key,
    required this.startdate,
    required this.datasets,
  });

  @override
  Widget build(BuildContext context) {
    return HeatMap(
      startDate: startdate,
      endDate: DateTime.now(),
      datasets: datasets,
      colorMode: ColorMode.color,
      defaultColor: context.colorScheme.surface,
      textColor: Colors.white,
      showColorTip: false,
      showText: true,
      scrollable: true,
      size: 30,
      colorsets: {
        1: Colors.green.shade300,
        2: Colors.green.shade400,
        3: Colors.green.shade500,
        4: Colors.green.shade600,
      },
    );
  }
}
