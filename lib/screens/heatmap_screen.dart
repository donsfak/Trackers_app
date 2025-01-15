// ignore_for_file: prefer_final_fields, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trackers_app/components/my_heatmap.dart';
import 'package:trackers_app/data/datasource/task_datasource.dart';

class HeatmapScreen extends StatefulWidget {
  static Widget builder(BuildContext context, GoRouterState state) {
    return HeatmapScreen();
  }

  const HeatmapScreen({super.key});

  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  Map<DateTime, int> _datasets = {};
  DateTime _startDate = DateTime.now()
      .subtract(const Duration(days: 30)); // Début : il y a 30 jours
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHeatmapData();
  }

  Future<void> _loadHeatmapData() async {
    final taskDatasource = TaskDatasource();
    try {
      final data = await taskDatasource.getTasksCountByDate();
      setState(() {
        _datasets = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Affichez un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des données : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heatmap'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: MyHeatmap(
                startdate: _startDate,
                datasets: _datasets,
              ),
            ),
    );
  }
}
