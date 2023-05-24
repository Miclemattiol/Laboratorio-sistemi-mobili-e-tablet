import 'package:flutter/material.dart';

const modalBorderRadius = Radius.circular(10);
InputDecoration inputDecoration(String labelText) => InputDecoration(border: const OutlineInputBorder(), labelText: labelText, contentPadding: const EdgeInsets.symmetric(horizontal: 12));

//TODO themes
final lightTheme = () {
  final colorScheme = ColorScheme.fromSeed(seedColor: const Color(0x00A6D0DD));

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    listTileTheme: const ListTileThemeData(iconColor: Colors.black),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
      headlineSmall: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    ),
  );
}();

//TODO dark theme
final darkTheme = () {
  return lightTheme;
}();
