import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mood.dart';

class JournalDataNotifier extends StateNotifier<Map<DateTime, Mood?>> {
  JournalDataNotifier() : super({});

  void updateMood(DateTime date, Mood newMood) {
    state = {...state, date: newMood};
  }
}

final journalProvider =
    StateNotifierProvider<JournalDataNotifier, Map<DateTime, Mood?>>((ref) {
  return JournalDataNotifier();
});

final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final isSavingProvider = StateProvider<bool>((ref) => false);
