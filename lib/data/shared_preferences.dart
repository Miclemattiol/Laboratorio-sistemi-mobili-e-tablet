import 'package:flutter/material.dart';
import 'package:house_wallet/utils.dart';
import 'package:shared_preferences/shared_preferences.dart' as package;

class SharedPreferences {
  final package.SharedPreferences _instance;

  SharedPreferences._(this._instance);

  static Future<SharedPreferences> getInstance() async => SharedPreferences._(await package.SharedPreferences.getInstance());

  static const _lastSectionKey = "last_section";
  int get lastSection => _instance.getInt(_lastSectionKey) ?? 0;
  Future<bool> setLastSection(int section) => _instance.setInt(_lastSectionKey, section);

  static const _themeKey = "theme";
  ThemeMode get theme => tryOrDefault(() => ThemeMode.values[_instance.getInt(_themeKey)!], ThemeMode.system);
  Future<bool> setTheme(ThemeMode theme) => _instance.setInt(_themeKey, theme.index);
}
