import 'package:shared_preferences/shared_preferences.dart' as package;

const _lastSectionKey = "last_section";

class SharedPreferences {
  final package.SharedPreferences _instance;

  SharedPreferences._(this._instance);

  static Future<SharedPreferences> getInstance() async => SharedPreferences._(await package.SharedPreferences.getInstance());

  int get lastSection => _instance.getInt(_lastSectionKey) ?? 0;
  Future<bool> setLastSection(int section) => _instance.setInt(_lastSectionKey, section);
}
