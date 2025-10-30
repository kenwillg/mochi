import 'package:flutter_riverpod/legacy.dart';

import '../models/mood.dart';

// --- Providers (Our App's "State") ---

// 1. THE "BRAIN" - This is our app's central database for moods.
class JournalDataNotifier extends StateNotifier<Map<DateTime, Mood?>> {
  JournalDataNotifier() : super({});

  void updateMood(DateTime date, Mood newMood) {
    // We create a new map so Riverpod knows to update the UI.
    state = {...state, date: newMood};
  }
}

final journalProvider =
    StateNotifierProvider<JournalDataNotifier, Map<DateTime, Mood?>>((ref) {
      return JournalDataNotifier();
    });

// 2. Holds the currently selected day on the calendar.
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// 3. Provider to handle the loading spinner state.
final isSavingProvider = StateProvider<bool>((ref) => false);
