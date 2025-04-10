// lib/screens/home_screen.dart

// ignore_for_file: avoid_print, use_build_context_synchronously, unused_local_variable, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:trackers_app/data/data.dart';
// Assurez-vous que tous les providers sont correctement exportés ou importés
import 'package:trackers_app/providers/providers.dart';
import 'package:trackers_app/screens/create_task_screen.dart';
import 'package:trackers_app/widgets/show_bottom_sheet.dart';
import 'package:trackers_app/utils/utils.dart';
import 'package:trackers_app/widgets/widgets.dart';
// Import pour la navigation GoRouter si utilisée
// import '../config/routes/route_location.dart';

class HomeScreen extends ConsumerWidget {
  static HomeScreen builder(BuildContext context, GoRouterState state) =>
      const HomeScreen();

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Récupération des thèmes et dimensions
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final deviceSize = MediaQuery.of(context).size;

    // Lecture des états depuis Riverpod
    final taskState =
        ref.watch(taskProvider); // Contient tasks, isLoading, error
    final selectDate = ref.watch(dateProvider);
    final currentThemeMode = ref.watch(themeNotifierProvider);

    // Filtrage des tâches pour la date sélectionnée
    final List<Task> tasksForSelectedDate = taskState.tasks
        .where((task) => Helpers.isTaskFromSelectedDate(task, selectDate))
        .toList();
    final completedTasks =
        tasksForSelectedDate.where((task) => task.isCompleted).toList();
    final incompletedTasks =
        tasksForSelectedDate.where((task) => !task.isCompleted).toList();

    // Fonction pour naviguer vers l'écran de création avec animation
    void navigateToCreateTask() {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (ctx, anim1, anim2) => CreateTaskScreen(),
          transitionsBuilder: (ctx, anim1, anim2, child) {
            return ScaleTransition(scale: anim1, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
      // Alternative GoRouter: context.push(RouteLocation.createTask);
    }

    return Scaffold(
      // AppBar configurée
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
            // Bouton pour changer le thème
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

      // FloatingActionButton pour l'ajout
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToCreateTask,
        tooltip: 'Ajouter une tâche',
        child: const Icon(Icons.add),
      ),

      // Corps principal
      body: Column(
        children: [
          // Affichage de la date sélectionnée
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: InkWell(
              onTap: () => Helpers.selectDate(context, ref),
              child: Text(
                DateFormat.yMMMd().format(selectDate), // Format d'affichage
                style: textTheme.titleMedium?.copyWith(color: colors.primary),
              ),
            ),
          ),

          // Section principale avec la liste des tâches
          Expanded(
            child: SingleChildScrollView(
              // Padding en bas pour ne pas masquer le contenu avec le FAB
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- GESTION ÉTAT GLOBAL (Chargement Initial / Erreur Initiale) ---
                  if (taskState.isLoading && taskState.tasks.isEmpty)
                    // Affiche un loader seulement au premier chargement
                    const Center(
                        child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 64.0),
                            child: CircularProgressIndicator()))
                  else if (taskState.error != null && taskState.tasks.isEmpty)
                    // Affiche une erreur seulement si le premier chargement échoue
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                color: colors.error, size: 40),
                            const SizedBox(height: 8),
                            Text("Erreur: ${taskState.error}",
                                textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text("Réessayer"),
                              // Style pour bouton d'erreur (optionnel)
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.errorContainer,
                                  foregroundColor: colors.onErrorContainer),
                              onPressed: () => ref
                                  .read(taskProvider.notifier)
                                  .getTasks(), // Action Réessayer
                            )
                          ],
                        ),
                      ),
                    )
                  else
                    // Si pas de chargement/erreur initiaux OU si on a déjà des tâches,
                    // on affiche les cartes des listes de tâches.
                    Column(
                      children: [
                        // Carte Tâches Incomplètes
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
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
                                    Text('Tâches à faire',
                                        style: textTheme.headlineSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // Affichage liste ou état vide
                                if (incompletedTasks.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 32.0),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Icon(Icons.check_circle_outline,
                                              size: 40,
                                              color: colors.primary
                                                  .withOpacity(0.5)),
                                          const SizedBox(height: 8),
                                          Text('Aucune tâche à faire !',
                                              style: textTheme.bodyMedium
                                                  ?.copyWith(
                                                      color: colors.onSurface
                                                          .withOpacity(0.6))),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  // Assurez-vous que DisplayListOfTasks a été mis à jour (avec Dismissible, ListTile, etc.)
                                  DisplayListOfTasks(tasks: incompletedTasks),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Carte Tâches Complètes
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
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
                                    Text('Tâches terminées',
                                        style: textTheme.headlineSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // Affichage liste ou état vide
                                if (completedTasks.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 32.0),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Icon(
                                              Icons
                                                  .sentiment_very_satisfied_outlined,
                                              size: 40,
                                              color: colors.onSurface
                                                  .withOpacity(0.4)),
                                          const SizedBox(height: 8),
                                          Text(
                                              'Aucune tâche terminée pour le moment.',
                                              style: textTheme.bodyMedium
                                                  ?.copyWith(
                                                      color: colors.onSurface
                                                          .withOpacity(0.6))),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  // Assurez-vous que DisplayListOfTasks a été mis à jour
                                  DisplayListOfTasks(
                                      tasks: completedTasks,
                                      isCompletedTasks: true),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20), // Espace final
                      ],
                    ),
                  // --- FIN GESTION ÉTAT GLOBAL ---
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
