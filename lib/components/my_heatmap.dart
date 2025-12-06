// lib/components/my_heatmap.dart
// ignore_for_file: unused_local_variable, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:intl/intl.dart';
// Pas besoin de Riverpod ici si on utilise juste Theme.of(context)

class MyHeatmap extends StatelessWidget {
  final Map<DateTime, int> datasets;
  final DateTime startDate;
  final Function(DateTime date, int? count)?
      onClick; // Signature onClick modifiée

  const MyHeatmap({
    super.key,
    required this.startDate,
    required this.datasets,
    this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Accéder au thème via le contexte
    final isDarkMode = theme.brightness == Brightness.dark;
    final textStyle = theme.textTheme.bodySmall ??
        const TextStyle(); // Style de base pour la légende

    // Couleurs adaptées (vous pouvez les affiner)
    final Map<int, Color> lightColorSet = {
      1: Colors.green[100]!,
      2: Colors.green[200]!,
      3: Colors.green[400]!,
      4: Colors.green[600]!,
      5: Colors.green[800]!,
    };

    final Map<int, Color> darkColorSet = {
      1: Colors.white.withOpacity(0.2),
      2: Colors.white.withOpacity(0.4),
      3: Colors.white.withOpacity(0.6),
      4: Colors.white.withOpacity(0.8),
      5: Colors.white,
    };

    // Force Dark Mode Logic because container is hardcoded to Dark Grey
    final currentColorsets = darkColorSet;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900], // Fond sombre premium
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: Colors.white70),
              const SizedBox(width: 10),
              Text(
                'Activity Log',
                style: textStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: HeatMap(
              // Gardons HeatMap si c'est ce que vous utilisiez
              startDate: startDate,
              endDate: DateTime.now()
                  .add(const Duration(days: 1)), // Inclure aujourd'hui
              datasets: datasets,
              colorMode: ColorMode.color,
              showColorTip: false, // La légende personnalisée est en dessous
              colorsets: currentColorsets, // Utiliser les couleurs adaptées
              defaultColor:
                  Colors.white.withOpacity(0.05), // Fixed visible empty color
              textColor: Colors.white, // Fixed visible text color
              size: 24, // Agrandissement des cases
              fontSize: 12, // Taille police lisible
              scrollable:
                  true, // Enable internal scrolling if supported, or for gesture handling

              onClick: (date) {
                // Appeler le callback fourni s'il existe
                onClick?.call(date, datasets[date]);

                // ----- Optionnel: Garder le SnackBar simple pour l'instant -----
                final taskCount = datasets[date] ?? 0;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '$taskCount tâches complétées le ${DateFormat.yMd().format(date)}'), // Préciser "complétées"
                    duration: const Duration(seconds: 2),
                  ),
                );
                // ----- Fin Optionnel -----
              },
            ),
          ),
          const SizedBox(height: 10), // Espace avant légende
          _buildLegend(
              context, currentColorsets), // Passer le contexte et les couleurs
        ],
      ),
    );
  }

  // La légende utilise maintenant les couleurs du thème et le style de texte
  Widget _buildLegend(BuildContext context, Map<int, Color> colorsets) {
    final theme = Theme.of(context);
    final legendTextStyle = theme.textTheme.bodySmall ?? const TextStyle();
    // Trouver les couleurs min et max utilisées dans le set actuel pour le dégradé
    // Vérifier si colorsets n'est pas vide pour éviter les erreurs
    final Color minColor = colorsets.isNotEmpty
        ? colorsets.entries.first.value
        : Colors.transparent;
    final Color maxColor = colorsets.isNotEmpty
        ? colorsets.entries.last.value
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Moins',
              style: legendTextStyle.copyWith(
                  color: Colors.white)), // Utiliser le style du thème
          const SizedBox(width: 8),
          Container(
            width: 100,
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5), // Bords arrondis
              gradient: LinearGradient(
                colors: [
                  minColor,
                  maxColor
                ], // Utiliser les couleurs min/max du set actuel
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('Plus',
              style: legendTextStyle.copyWith(
                  color: Colors.white)), // Utiliser le style du thème
        ],
      ),
    );
  }
}
