import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../models/journal_entry.dart';
import '../models/mood.dart';
import '../models/weather_info.dart';
import '../services/journal_storage_factory.dart';
import '../services/journal_storage_service.dart';
import '../services/preferences_service.dart';

// --- Providers (Our App's "State") ---

DateTime _normalize(DateTime date) => DateTime(date.year, date.month, date.day);

// Provider for storage service (accessible across files)
// Automatically uses SQLite on mobile/desktop, SharedPreferences on web
final storageServiceProvider = Provider<JournalStorageService>((ref) {
  return JournalStorageFactory.create();
});

// Provider for preferences service (accessible across files)
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService();
});

// 1. THE "BRAIN" - This is our app's central database for entries.
// Now with platform-agnostic persistence (SQLite on mobile/desktop, SharedPreferences on web)
class JournalDataNotifier extends Notifier<Map<DateTime, JournalEntry>> {
  JournalStorageService get _storageService => ref.read(storageServiceProvider);
  bool _isLoading = false;

  @override
  Map<DateTime, JournalEntry> build() {
    // Load from database on initialization
    _loadFromDatabase();
    return {};
  }

  /// Load all entries from database on initialization
  Future<void> _loadFromDatabase() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      if (kDebugMode) {
        debugPrint('[JournalProvider] Loading entries from database...');
      }

      final entries = await _storageService.loadAllEntries();
      state = entries;

      if (kDebugMode) {
        debugPrint(
          '[JournalProvider] Loaded ${entries.length} entries from database',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[JournalProvider] Error loading from database: $e');
      }
    } finally {
      _isLoading = false;
    }
  }

  /// Save entry to database
  Future<void> _saveToDatabase(DateTime date, JournalEntry entry) async {
    try {
      await _storageService.saveEntry(date, entry);
      if (kDebugMode) {
        debugPrint(
          '[JournalProvider] Saved entry to database for date: ${_normalize(date)}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[JournalProvider] Error saving to database: $e');
      }
      // Don't rethrow - we still want the state to update even if save fails
    }
  }

  JournalEntry entryFor(DateTime date) {
    final normalized = _normalize(date);
    return state[normalized] ?? const JournalEntry();
  }

  void updateMood(DateTime date, Mood newMood, {WeatherInfo? weather}) {
    final normalized = _normalize(date);
    final current = entryFor(normalized);
    final updated = current.copyWith(
      mood: newMood,
      weather: weather ?? current.weather, // Keep existing weather if not provided
    );

    state = {...state, normalized: updated};

    // Persist to database
    _saveToDatabase(normalized, updated);
  }

  void updateCanvas(
    DateTime date, {
    List<DrawnStroke>? strokes,
    List<StickerPlacement>? stickers,
    List<TextPlacement>? texts,
  }) {
    final normalized = _normalize(date);
    final current = entryFor(normalized);
    final updated = current.copyWith(
      strokes: strokes ?? current.strokes,
      stickers: stickers ?? current.stickers,
      texts: texts ?? current.texts,
    );

    state = {...state, normalized: updated};

    // Persist to database
    _saveToDatabase(normalized, updated);
  }

  /// Manually reload from database (useful for debugging)
  Future<void> reloadFromDatabase() async {
    await _loadFromDatabase();
  }
}

final journalProvider =
    NotifierProvider<JournalDataNotifier, Map<DateTime, JournalEntry>>(
      JournalDataNotifier.new,
    );

// 2. Holds the currently selected day on the calendar.
class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void setDate(DateTime date) {
    state = date;
  }
}

final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime>(
  SelectedDateNotifier.new,
);

// 3. Provider to handle the loading spinner state.
class IsSavingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setSaving(bool value) {
    state = value;
  }
}

final isSavingProvider = NotifierProvider<IsSavingNotifier, bool>(
  IsSavingNotifier.new,
);
