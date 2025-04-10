import 'package:flutter/material.dart';

final ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue, // Peut être la même ou une autre couleur
    brightness: Brightness.dark,
    // Vous pouvez ajuster les couleurs spécifiques du mode sombre ici si nécessaire
    // primary: Colors.blue[300],
  ),
  useMaterial3: true,
  // Personnalisations spécifiques au mode sombre
  // appBarTheme: AppBarTheme( ... ),
);
