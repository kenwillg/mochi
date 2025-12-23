import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mochi/providers/journal_providers.dart';
import 'package:mochi/models/journal_entry.dart';
import 'package:mochi/models/mood.dart';
import 'package:mochi/models/weather_info.dart';
import 'package:mochi/services/journal_storage_service.dart';
import 'package:mochi/services/preferences_service.dart';
import 'package:flutter/material.dart';

// Mock storage service for testing
class MockJournalStorageService implements JournalStorageService {
  final Map<DateTime, JournalEntry> _entries = {};

  @override
  Future<void> saveEntry(DateTime date, JournalEntry entry) async {
    _entries[date] = entry;
  }

  @override
  Future<JournalEntry?> loadEntry(DateTime date) async {
    return _entries[date];
  }

  @override
  Future<Map<DateTime, JournalEntry>> loadAllEntries() async {
    return Map.from(_entries);
  }

  @override
  Future<void> deleteEntry(DateTime date) async {
    _entries.remove(date);
  }

  void clear() {
    _entries.clear();
  }
}

void main() {
  late ProviderContainer container;
  late MockJournalStorageService mockStorage;

  setUp(() {
    mockStorage = MockJournalStorageService();
    container = ProviderContainer(
      overrides: [
        storageServiceProvider.overrideWithValue(mockStorage),
        preferencesServiceProvider.overrideWithValue(PreferencesService()),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    mockStorage.clear();
  });

  group('JournalDataNotifier', () {
    test('should initialize with empty map', () {
      final state = container.read(journalProvider);

      expect(state, isEmpty);
    });

    test('entryFor should return empty entry for non-existent date', () {
      final notifier = container.read(journalProvider.notifier);
      final date = DateTime(2024, 1, 15);
      final entry = notifier.entryFor(date);

      expect(entry.mood, isNull);
      expect(entry.strokes, isEmpty);
      expect(entry.stickers, isEmpty);
      expect(entry.texts, isEmpty);
    });

    test('entryFor should return existing entry', () async {
      final notifier = container.read(journalProvider.notifier);
      final date = DateTime(2024, 1, 15);
      const entry = JournalEntry(mood: Mood.happy);

      await mockStorage.saveEntry(date, entry);
      await notifier.reloadFromDatabase();

      final retrieved = notifier.entryFor(date);
      expect(retrieved.mood, equals(Mood.happy));
    });

    test('updateMood should update mood for date', () {
      final notifier = container.read(journalProvider.notifier);
      final date = DateTime(2024, 1, 15);

      notifier.updateMood(date, Mood.happy);

      // State should be updated immediately (synchronously)
      final state = container.read(journalProvider);
      final normalizedDate = DateTime(2024, 1, 15);
      expect(state[normalizedDate]?.mood, equals(Mood.happy));
    });

    test('updateMood should preserve existing weather', () {
      final notifier = container.read(journalProvider.notifier);
      final date = DateTime(2024, 1, 15);
      final weather = WeatherInfo(
        locationName: 'Jakarta',
        region: 'Jakarta',
        country: 'Indonesia',
        lastUpdated: DateTime.now(),
        temperatureC: 30.0,
        feelsLikeC: 32.0,
        humidity: 70,
        windSpeedKph: 10.0,
        chanceOfRain: 20,
        uvIndex: 5.0,
        conditionText: 'Sunny',
        conditionIconUrl: 'https://example.com/icon.png',
        airQualityIndex: 3,
      );

      notifier.updateMood(date, Mood.happy, weather: weather);
      
      notifier.updateMood(date, Mood.sad);

      final state = container.read(journalProvider);
      final normalizedDate = DateTime(2024, 1, 15);
      final entry = state[normalizedDate];
      expect(entry?.mood, equals(Mood.sad));
      expect(entry?.weather, isNotNull);
      expect(entry?.weather?.locationName, equals('Jakarta'));
    });

    test('updateCanvas should update strokes', () {
      final notifier = container.read(journalProvider.notifier);
      final date = DateTime(2024, 1, 15);
      final strokes = [
        DrawnStroke(points: [const Offset(10, 20)], color: Colors.red),
      ];

      notifier.updateCanvas(date, strokes: strokes);

      final state = container.read(journalProvider);
      final normalizedDate = DateTime(2024, 1, 15);
      final entry = state[normalizedDate];
      expect(entry?.strokes.length, equals(1));
      expect(entry?.strokes[0].color.value, equals(Colors.red.value));
    });

    test('updateCanvas should update stickers', () {
      final notifier = container.read(journalProvider.notifier);
      final date = DateTime(2024, 1, 15);
      const stickers = [
        StickerPlacement(mood: Mood.happy, position: Offset(10, 20)),
      ];

      notifier.updateCanvas(date, stickers: stickers);

      final state = container.read(journalProvider);
      final normalizedDate = DateTime(2024, 1, 15);
      final entry = state[normalizedDate];
      expect(entry?.stickers.length, equals(1));
      expect(entry?.stickers[0].mood, equals(Mood.happy));
    });

    test('updateCanvas should update texts', () {
      final notifier = container.read(journalProvider.notifier);
      final date = DateTime(2024, 1, 15);
      const texts = [
        TextPlacement(text: 'Hello', position: Offset(10, 20)),
      ];

      notifier.updateCanvas(date, texts: texts);

      final state = container.read(journalProvider);
      final normalizedDate = DateTime(2024, 1, 15);
      final entry = state[normalizedDate];
      expect(entry?.texts.length, equals(1));
      expect(entry?.texts[0].text, equals('Hello'));
    });

    test('updateCanvas should update all canvas elements', () {
      final notifier = container.read(journalProvider.notifier);
      final date = DateTime(2024, 1, 15);
      final strokes = [
        DrawnStroke(points: [const Offset(10, 20)], color: Colors.red),
      ];
      const stickers = [
        StickerPlacement(mood: Mood.happy, position: Offset(30, 40)),
      ];
      const texts = [
        TextPlacement(text: 'Test', position: Offset(50, 60)),
      ];

      notifier.updateCanvas(
        date,
        strokes: strokes,
        stickers: stickers,
        texts: texts,
      );

      final state = container.read(journalProvider);
      final normalizedDate = DateTime(2024, 1, 15);
      final entry = state[normalizedDate];
      expect(entry?.strokes.length, equals(1));
      expect(entry?.stickers.length, equals(1));
      expect(entry?.texts.length, equals(1));
    });

    test('should normalize date to remove time component', () {
      final notifier = container.read(journalProvider.notifier);
      final date1 = DateTime(2024, 1, 15, 10, 30, 45);
      final date2 = DateTime(2024, 1, 15, 20, 15, 30);

      notifier.updateMood(date1, Mood.happy);

      final entry = notifier.entryFor(date2);
      expect(entry.mood, equals(Mood.happy));
    });
  });

  group('SelectedDateNotifier', () {
    test('should initialize with current date', () {
      final state = container.read(selectedDateProvider);

      expect(state, isA<DateTime>());
    });

    test('setDate should update selected date', () {
      final notifier = container.read(selectedDateProvider.notifier);
      final newDate = DateTime(2024, 1, 15);

      notifier.setDate(newDate);

      final state = container.read(selectedDateProvider);
      expect(state.year, equals(2024));
      expect(state.month, equals(1));
      expect(state.day, equals(15));
    });
  });

  group('IsSavingNotifier', () {
    test('should initialize with false', () {
      final state = container.read(isSavingProvider);
      expect(state, isFalse);
    });

    test('setSaving should update saving state', () {
      final notifier = container.read(isSavingProvider.notifier);

      notifier.setSaving(true);
      expect(container.read(isSavingProvider), isTrue);

      notifier.setSaving(false);
      expect(container.read(isSavingProvider), isFalse);
    });
  });
}

