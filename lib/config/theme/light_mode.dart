import 'package:flutter/material.dart';

final ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue, // Choisissez votre couleur principale
    brightness: Brightness.light,
  ),
  useMaterial3: true,
  // Vous pouvez personnaliser d'autres éléments ici :
  // appBarTheme: AppBarTheme( ... ),
  // elevatedButtonTheme: ElevatedButtonThemeData( ... ),
  // textTheme: TextTheme( ... ),
);
