// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:intl/intl.dart';

class MyHeatmap extends StatelessWidget {
  final Map<DateTime, int> datasets;
  final DateTime startdate;

  const MyHeatmap({
    super.key,
    required this.startdate,
    required this.datasets,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMonthsRow(),
        HeatMap(
          startDate: startdate,
          endDate: DateTime.now(),
          datasets: datasets,
          colorMode: ColorMode.color,
          showColorTip: false,
          colorsets: {
            1: Colors.green.shade200,
            2: Colors.green.shade300,
            3: Colors.green.shade400,
            4: Colors.green.shade500,
            5: Colors.green.shade800,
          },
        ),
      ],
    );
  }

  Widget _buildMonthsRow() {
    final months = List.generate(
        12, (index) => DateFormat.MMM().format(DateTime(0, index + 1)));
    return Row(
      //mainAxisAlignment: MainAxisAlignment.center,

      mainAxisAlignment: MainAxisAlignment.spaceAround,
      //children: months.map((month) => Text(month)).toList(),
    );
  }
}
