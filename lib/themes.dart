import 'package:flutter/material.dart';

//TODO themes
final lightTheme = ThemeData(
  primarySwatch: Colors.blueGrey,
  listTileTheme: const ListTileThemeData(iconColor: Colors.black),
  textTheme: const TextTheme(
    headlineSmall: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
  ),
);

//TODO dark theme
final darkTheme = lightTheme;