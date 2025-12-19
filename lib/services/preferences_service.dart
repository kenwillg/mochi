import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app preferences using SharedPreferences
/// Provides debugging capabilities with detailed logging
class PreferencesService {
  static const String _keyLastSyncDate = 'last_sync_date';
  static const String _keyFirstLaunch = 'first_launch';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyUserName = 'user_name';

  SharedPreferences? _prefs;

  /// Get SharedPreferences instance
  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Save last sync date
  Future<void> setLastSyncDate(DateTime date) async {
    try {
      final prefs = await this.prefs;
      final timestamp = date.millisecondsSinceEpoch;
      await prefs.setInt(_keyLastSyncDate, timestamp);

      if (kDebugMode) {
        debugPrint('[PreferencesService] Saved last sync date: $date');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PreferencesService] Error saving last sync date: $e');
      }
      rethrow;
    }
  }

  /// Get last sync date
  Future<DateTime?> getLastSyncDate() async {
    try {
      final prefs = await this.prefs;
      final timestamp = prefs.getInt(_keyLastSyncDate);
      if (timestamp == null) return null;

      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (kDebugMode) {
        debugPrint('[PreferencesService] Loaded last sync date: $date');
      }
      return date;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PreferencesService] Error loading last sync date: $e');
      }
      return null;
    }
  }

  /// Check if this is the first launch
  Future<bool> isFirstLaunch() async {
    try {
      final prefs = await this.prefs;
      final isFirst = prefs.getBool(_keyFirstLaunch) ?? true;
      if (kDebugMode) {
        debugPrint('[PreferencesService] Is first launch: $isFirst');
      }
      return isFirst;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PreferencesService] Error checking first launch: $e');
      }
      return true;
    }
  }

  /// Set first launch flag to false
  Future<void> setFirstLaunchComplete() async {
    try {
      final prefs = await this.prefs;
      await prefs.setBool(_keyFirstLaunch, false);
      if (kDebugMode) {
        debugPrint('[PreferencesService] First launch completed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PreferencesService] Error setting first launch: $e');
      }
      rethrow;
    }
  }

  /// Save theme mode preference
  Future<void> setThemeMode(String themeMode) async {
    try {
      final prefs = await this.prefs;
      await prefs.setString(_keyThemeMode, themeMode);
      if (kDebugMode) {
        debugPrint('[PreferencesService] Saved theme mode: $themeMode');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PreferencesService] Error saving theme mode: $e');
      }
      rethrow;
    }
  }

  /// Get theme mode preference
  Future<String?> getThemeMode() async {
    try {
      final prefs = await this.prefs;
      final themeMode = prefs.getString(_keyThemeMode);
      if (kDebugMode) {
        debugPrint('[PreferencesService] Loaded theme mode: $themeMode');
      }
      return themeMode;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PreferencesService] Error loading theme mode: $e');
      }
      return null;
    }
  }

  /// Save user name
  Future<void> setUserName(String name) async {
    try {
      final prefs = await this.prefs;
      await prefs.setString(_keyUserName, name);
      if (kDebugMode) {
        debugPrint('[PreferencesService] Saved user name: $name');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PreferencesService] Error saving user name: $e');
      }
      rethrow;
    }
  }

  /// Get user name
  Future<String?> getUserName() async {
    try {
      final prefs = await this.prefs;
      final name = prefs.getString(_keyUserName);
      if (kDebugMode) {
        debugPrint('[PreferencesService] Loaded user name: $name');
      }
      return name;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PreferencesService] Error loading user name: $e');
      }
      return null;
    }
  }

  /// Clear all preferences (for debugging/testing)
  Future<void> clearAll() async {
    try {
      final prefs = await this.prefs;
      await prefs.clear();
      if (kDebugMode) {
        debugPrint('[PreferencesService] Cleared all preferences');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PreferencesService] Error clearing preferences: $e');
      }
      rethrow;
    }
  }
}

