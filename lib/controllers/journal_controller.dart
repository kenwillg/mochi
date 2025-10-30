import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mochi/models/mood.dart';

class JournalController extends StateNotifier<Map<DateTime, Mood?>> {
  JournalController() : super({});

  void updateMood(DateTime date, Mood newMood) {
    state = {...state, date: newMood};
  }
}

final journalControllerProvider =
    StateNotifierProvider<JournalController, Map<DateTime, Mood?>>((ref) {
  return JournalController();
});

final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final isSavingProvider = StateProvider<bool>((ref) => false);
