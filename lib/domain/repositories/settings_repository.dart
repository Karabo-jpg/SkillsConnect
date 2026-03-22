abstract class SettingsRepository {
  Future<void> saveThemeMode(bool isDarkMode);
  Future<bool> getThemeMode();
  
  Future<void> saveOnboardingSeen(bool hasSeen);
  Future<bool> isOnboardingSeen();
  
  Future<void> saveLastSearchQuery(String query);
  Future<String?> getLastSearchQuery();
}
