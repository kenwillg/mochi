import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/journal_entry.dart';
import '../models/mood.dart';

// --- Providers (Our App's "State") ---

DateTime _normalize(DateTime date) => DateTime(date.year, date.month, date.day);

// 1. THE "BRAIN" - This is our app's central database for entries.
class JournalDataNotifier extends StateNotifier<Map<DateTime, JournalEntry>> {
  JournalDataNotifier() : super({});

  JournalEntry entryFor(DateTime date) {
    final normalized = _normalize(date);
    return state[normalized] ?? const JournalEntry();
  }

  void updateMood(DateTime date, Mood newMood) {
    final normalized = _normalize(date);
    final current = entryFor(normalized);
    state = {
      ...state,
      normalized: current.copyWith(mood: newMood),
    };
  }

  void updateCanvas(
    DateTime date, {
    List<DrawnStroke>? strokes,
    List<StickerPlacement>? stickers,
  }) {
    final normalized = _normalize(date);
    final current = entryFor(normalized);
    state = {
      ...state,
      normalized: current.copyWith(
        strokes: strokes ?? current.strokes,
        stickers: stickers ?? current.stickers,
      ),
    };
  }
}

final journalProvider =
    StateNotifierProvider<JournalDataNotifier, Map<DateTime, JournalEntry>>(
  (ref) => JournalDataNotifier(),
);

// 2. Holds the currently selected day on the calendar.
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// 3. Provider to handle the loading spinner state.
final isSavingProvider = StateProvider<bool>((ref) => false);
