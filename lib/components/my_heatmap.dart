import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:intl/intl.dart';

class MyHeatmap extends StatelessWidget {
  final Map<DateTime, int> datasets;
  final DateTime startDate;

  const MyHeatmap({
    super.key,
    required this.startDate,
    required this.datasets,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: HeatMap(
                startDate: startDate,
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
                onClick: (date) {
                  final taskCount = datasets[date] ?? 0;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            '$taskCount tâches le ${DateFormat.yMd().format(date)}')),
                  );
                },
              ),
            ),
          ],
        ),
        _buildLegend(),
      ],
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Less',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 100,
            height: 10,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade200,
                  Colors.green.shade800,
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'More',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
