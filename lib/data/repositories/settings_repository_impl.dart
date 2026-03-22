import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPreferences sharedPreferences;

  SettingsRepositoryImpl({required this.sharedPreferences});

  static const String _keyThemeMode = 'theme_mode';
  static const String _keyOnboardingSeen = 'onboarding_seen';
  static const String _keyLastSearch = 'last_search';

  @override
  Future<void> saveThemeMode(bool isDarkMode) async {
    await sharedPreferences.setBool(_keyThemeMode, isDarkMode);
  }

  @override
  Future<bool> getThemeMode() async {
    return sharedPreferences.getBool(_keyThemeMode) ?? false;
  }

  @override
  Future<void> saveOnboardingSeen(bool hasSeen) async {
    await sharedPreferences.setBool(_keyOnboardingSeen, hasSeen);
  }

  @override
  Future<bool> isOnboardingSeen() async {
    return sharedPreferences.getBool(_keyOnboardingSeen) ?? false;
  }

  @override
  Future<void> saveLastSearchQuery(String query) async {
    await sharedPreferences.setString(_keyLastSearch, query);
  }

  @override
  Future<String?> getLastSearchQuery() async {
    return sharedPreferences.getString(_keyLastSearch);
  }
}
