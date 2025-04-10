// lib/screens/home_screen.dart

// ignore_for_file: avoid_print, use_build_context_synchronously, unused_local_variable, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:trackers_app/data/data.dart';
// Assurez-vous que themeNotifierProvider est exporté depuis providers.dart ou importé directement
import 'package:trackers_app/providers/providers.dart';
import 'package:trackers_app/screens/create_task_screen.dart';
import 'package:trackers_app/widgets/show_bottom_sheet.dart';
import 'package:trackers_app/utils/utils.dart';
import 'package:trackers_app/widgets/widgets.dart';
// Assurez-vous d'importer vos routes si vous utilisez GoRouter pour la navigation
// import '../config/routes/route_location.dart';

// Convertir en ConsumerWidget pour un accès direct à ref
class HomeScreen extends ConsumerWidget {
  static HomeScreen builder(BuildContext context, GoRouterState state) =>
      const HomeScreen();

  const HomeScreen({super.key});

  @override
  // Ajout de WidgetRef ref ici
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme; // Récupérer le textTheme
    final deviceSize = MediaQuery.of(context).size;

    // Utiliser 'ref' directement car c'est un ConsumerWidget
    final taskState =
        ref.watch(taskProvider); // taskProvider doit être un provider Riverpod
    final selectDate =
        ref.watch(dateProvider); // dateProvider doit être un provider Riverpod
    // --- Ajout pour le thème ---
    final currentThemeMode = ref.watch(themeNotifierProvider);
    // --- Fin Ajout ---

    // --- Filtrage des tâches intégré ici ---
    // S'assurer que taskState.tasks existe bien (ajuster si la structure de TaskState est différente)
    final List<Task> tasksForSelectedDate = taskState.tasks
        .where((task) => Helpers.isTaskFromSelectedDate(task, selectDate))
        .toList();
    final completedTasks =
        tasksForSelectedDate.where((task) => task.isCompleted).toList();
    final incompletedTasks =
        tasksForSelectedDate.where((task) => !task.isCompleted).toList();
    // --- Fin Filtrage ---

    // --- La logique onPressed pour la navigation AVEC animation ---
    void navigateToCreateTask() {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              CreateTaskScreen(), // Assurez-vous que c'est bien un Widget
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            return ScaleTransition(
              // Garde l'animation
              scale: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300), // Optionnel
        ),
      );
      // Ou: context.push(RouteLocation.createTask); // Si GoRouter configuré
    }
    // --- Fin logique onPressed ---

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        elevation: 0,
        title: const Text('Mon Todo List',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          tooltip: 'Menu',
          onPressed: () {
            showCustomBottomSheet(context);
            print("Menu button clicked");
          },
        ),
        actions: [
          IconButton(
            // Bouton Thème
            icon: Icon(
              currentThemeMode == ThemeMode.light
                  ? Icons.dark_mode_outlined
                  : currentThemeMode == ThemeMode.dark
                      ? Icons.light_mode_outlined
                      : Icons.brightness_auto_outlined,
              color: Colors.white,
            ),
            tooltip: 'Changer de thème',
            onPressed: () {
              final themeNotifier = ref.read(themeNotifierProvider.notifier);
              ThemeMode newMode;
              if (currentThemeMode == ThemeMode.light) {
                newMode = ThemeMode.dark;
              } else if (currentThemeMode == ThemeMode.dark) {
                newMode = ThemeMode.system;
              } else {
                newMode = ThemeMode.light;
              }
              themeNotifier.setThemeMode(newMode);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // FAB pour ajouter
        onPressed: navigateToCreateTask,
        tooltip: 'Ajouter une tâche',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Affichage de la date
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: InkWell(
              onTap: () => Helpers.selectDate(context, ref),
              child: Text(
                DateFormat.yMMMd().format(selectDate),
                style: textTheme.titleMedium?.copyWith(color: colors.primary),
              ),
            ),
          ),

          // Section des tâches
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  20, 0, 20, 80), // Padding bas pour FAB
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Tâches incomplètes ---
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            // En-tête
                            children: [
                              Icon(Icons.assignment_outlined,
                                  color: colors.primary),
                              const SizedBox(width: 10),
                              Text(
                                'Tâches à faire',
                                style: textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // --- GESTION ÉTAT VIDE (Suggestion 1) ---
                          if (incompletedTasks.isEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 32.0),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons
                                          .check_circle_outline, // Icône état vide
                                      size: 40,
                                      color: colors.primary.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Aucune tâche à faire !',
                                      textAlign: TextAlign.center,
                                      style: textTheme.bodyMedium?.copyWith(
                                          color: colors.onSurface
                                              .withOpacity(0.6)),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            DisplayListOfTasks(
                              tasks: incompletedTasks,
                              // isCompletedTasks: false, // Valeur par défaut, pas besoin de spécifier
                              // Pas besoin de onTaskToggle ici si géré dans DisplayListOfTasks/ListTile
                            ),
                          // --- FIN GESTION ÉTAT VIDE ---
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Tâches complètes ---
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            // En-tête
                            children: [
                              Icon(Icons.check_circle_outline,
                                  color: colors.primary),
                              const SizedBox(width: 10),
                              Text(
                                'Tâches terminées',
                                style: textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // --- GESTION ÉTAT VIDE (Suggestion 1) ---
                          if (completedTasks.isEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 32.0),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons
                                          .sentiment_very_satisfied_outlined, // Icône état vide
                                      size: 40,
                                      color: colors.onSurface.withOpacity(0.4),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Aucune tâche terminée pour le moment.',
                                      textAlign: TextAlign.center,
                                      style: textTheme.bodyMedium?.copyWith(
                                          color: colors.onSurface
                                              .withOpacity(0.6)),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            DisplayListOfTasks(
                              tasks: completedTasks,
                              isCompletedTasks: true,
                              // Pas besoin de onTaskToggle ici si géré dans DisplayListOfTasks/ListTile
                            ),
                          // --- FIN GESTION ÉTAT VIDE ---
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                      height:
                          20), // Espace avant la fin effective du contenu scrollable
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Les méthodes _completedTasks et _incompletedTasks ne sont plus nécessaires ici
  // car le filtrage est fait directement dans la méthode build.

  // La méthode _toggleTaskCompletion n'est plus nécessaire ici car la logique
  // est maintenant dans le onChanged du Checkbox dans DisplayListOfTasks (via ListTile).
}
