import 'package:flutter/material.dart';
import 'package:house_wallet/main.dart';

class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier(super.value);

  @override
  set value(ThemeMode? newValue) {
    super.value = newValue ?? ThemeMode.system;
    prefs.setTheme(value);
  }
}

InputDecoration inputDecoration(String labelText, [bool multiline = false]) {
  return InputDecoration(
    border: const OutlineInputBorder(),
    labelText: labelText,
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: multiline ? 8 : 0),
  );
}

//TODO themes
ThemeData get lightTheme {
  final colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFFA6D0DD), brightness: Brightness.light);
  final theme = ThemeData(colorScheme: colorScheme);
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    listTileTheme: const ListTileThemeData(iconColor: Colors.black),
    iconTheme: const IconThemeData(color: Colors.black),
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
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: theme.unselectedWidgetColor,
    ),
    dialogTheme: const DialogTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
    ),
  );
}

//TODO dark theme
ThemeData get darkTheme {
  final colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFFA6D0DD), brightness: Brightness.dark);
  final theme = ThemeData(colorScheme: colorScheme);
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: theme.unselectedWidgetColor,
    ),
  );
}
