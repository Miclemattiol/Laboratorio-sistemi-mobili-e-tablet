import 'package:flutter/material.dart';

//TODO themes
final lightTheme = ThemeData(
  useMaterial3: true,
  colorSchemeSeed: const Color(0x00A6D0DD),
  listTileTheme: const ListTileThemeData(iconColor: Colors.black),
  textTheme: const TextTheme(
    headlineSmall: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
  ),
);

//TODO dark theme
final darkTheme = lightTheme;
