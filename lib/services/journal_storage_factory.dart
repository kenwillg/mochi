import 'package:flutter/foundation.dart';

import 'journal_database_service.dart';
import 'journal_storage_service.dart'
    show JournalStorageService, WebJournalStorageService;

/// Factory to create the appropriate storage service based on platform
class JournalStorageFactory {
  /// Creates a storage service appropriate for the current platform
  /// - Web: Uses SharedPreferences (WebJournalStorageService)
  /// - Mobile/Desktop: Uses SQLite (JournalDatabaseService)
  static JournalStorageService create() {
    if (kIsWeb) {
      if (kDebugMode) {
        debugPrint('[JournalStorageFactory] Creating web storage service');
      }
      return WebJournalStorageService();
    } else {
      if (kDebugMode) {
        debugPrint('[JournalStorageFactory] Creating SQLite storage service');
      }
      return JournalDatabaseService();
    }
  }
}
