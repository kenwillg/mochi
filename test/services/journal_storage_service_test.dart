import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mochi/services/journal_storage_service.dart';
import 'package:mochi/models/journal_entry.dart';
import 'package:mochi/models/mood.dart';
import 'package:mochi/models/weather_info.dart';
import 'package:flutter/material.dart';

void main() {
  late WebJournalStorageService service;

  setUp(() async {
    // Use in-memory SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    service = WebJournalStorageService();
  });

  group('WebJournalStorageService', () {
    group('Save and Load Entry', () {
      test('should save and load a simple entry with mood', () async {
        final date = DateTime(2024, 1, 15);
        final entry = const JournalEntry(mood: Mood.happy);

        await service.saveEntry(date, entry);
        final loaded = await service.loadEntry(date);

        expect(loaded, isNotNull);
        expect(loaded!.mood, equals(Mood.happy));
      });

      test('should return null when entry does not exist', () async {
        final date = DateTime(2024, 1, 15);
        final loaded = await service.loadEntry(date);

        expect(loaded, isNull);
      });

      test('should save and load entry with strokes', () async {
        final date = DateTime(2024, 1, 15);
        final strokes = [
          DrawnStroke(
            points: [const Offset(10, 20), const Offset(30, 40)],
            color: Colors.red,
          ),
          DrawnStroke(
            points: [const Offset(50, 60)],
            color: Colors.blue,
          ),
        ];
        final entry = JournalEntry(strokes: strokes);

        await service.saveEntry(date, entry);
        final loaded = await service.loadEntry(date);

        expect(loaded, isNotNull);
        expect(loaded!.strokes.length, equals(2));
        expect(loaded.strokes[0].points.length, equals(2));
        expect(loaded.strokes[0].color.value, equals(Colors.red.value));
        expect(loaded.strokes[1].points.length, equals(1));
        expect(loaded.strokes[1].color.value, equals(Colors.blue.value));
      });

      test('should save and load entry with stickers', () async {
        final date = DateTime(2024, 1, 15);
        const stickers = [
          StickerPlacement(
            mood: Mood.happy,
            position: Offset(10, 20),
            size: 72,
          ),
          StickerPlacement(
            mood: Mood.sad,
            position: Offset(30, 40),
            size: 100,
          ),
        ];
        const entry = JournalEntry(stickers: stickers);

        await service.saveEntry(date, entry);
        final loaded = await service.loadEntry(date);

        expect(loaded, isNotNull);
        expect(loaded!.stickers.length, equals(2));
        expect(loaded.stickers[0].mood, equals(Mood.happy));
        expect(loaded.stickers[0].position, equals(const Offset(10, 20)));
        expect(loaded.stickers[0].size, equals(72));
        expect(loaded.stickers[1].mood, equals(Mood.sad));
        expect(loaded.stickers[1].size, equals(100));
      });

      test('should save and load entry with texts', () async {
        final date = DateTime(2024, 1, 15);
        const texts = [
          TextPlacement(
            text: 'Hello',
            position: Offset(10, 20),
            color: Colors.red,
            fontSize: 16.0,
          ),
          TextPlacement(
            text: 'World',
            position: Offset(30, 40),
            color: Colors.blue,
            fontSize: 24.0,
          ),
        ];
        const entry = JournalEntry(texts: texts);

        await service.saveEntry(date, entry);
        final loaded = await service.loadEntry(date);

        expect(loaded, isNotNull);
        expect(loaded!.texts.length, equals(2));
        expect(loaded.texts[0].text, equals('Hello'));
        expect(loaded.texts[0].position, equals(const Offset(10, 20)));
        expect(loaded.texts[0].color.value, equals(Colors.red.value));
        expect(loaded.texts[0].fontSize, equals(16.0));
        expect(loaded.texts[1].text, equals('World'));
        expect(loaded.texts[1].fontSize, equals(24.0));
      });

      test('should save and load entry with weather', () async {
        final date = DateTime(2024, 1, 15);
        final weather = WeatherInfo(
          locationName: 'Jakarta',
          region: 'Jakarta',
          country: 'Indonesia',
          lastUpdated: DateTime(2024, 1, 15, 12, 0),
          temperatureC: 30.5,
          feelsLikeC: 32.0,
          humidity: 70,
          windSpeedKph: 15.5,
          chanceOfRain: 20,
          uvIndex: 5.5,
          conditionText: 'Sunny',
          conditionIconUrl: 'https://example.com/icon.png',
          airQualityIndex: 3,
        );
        final entry = JournalEntry(weather: weather);

        await service.saveEntry(date, entry);
        final loaded = await service.loadEntry(date);

        expect(loaded, isNotNull);
        expect(loaded!.weather, isNotNull);
        expect(loaded.weather!.locationName, equals('Jakarta'));
        expect(loaded.weather!.temperatureC, equals(30.5));
        expect(loaded.weather!.humidity, equals(70));
      });

      test('should save and load complete entry with all fields', () async {
        final date = DateTime(2024, 1, 15);
        final weather = WeatherInfo(
          locationName: 'Jakarta',
          region: 'Jakarta',
          country: 'Indonesia',
          lastUpdated: DateTime(2024, 1, 15, 12, 0),
          temperatureC: 30.5,
          feelsLikeC: 32.0,
          humidity: 70,
          windSpeedKph: 15.5,
          chanceOfRain: 20,
          uvIndex: 5.5,
          conditionText: 'Sunny',
          conditionIconUrl: 'https://example.com/icon.png',
          airQualityIndex: 3,
        );
        final entry = JournalEntry(
          mood: Mood.happy,
          strokes: [
            DrawnStroke(points: [const Offset(10, 20)], color: Colors.red),
          ],
          stickers: [
            const StickerPlacement(
              mood: Mood.happy,
              position: Offset(30, 40),
            ),
          ],
          texts: [
            const TextPlacement(
              text: 'Test',
              position: Offset(50, 60),
            ),
          ],
          weather: weather,
        );

        await service.saveEntry(date, entry);
        final loaded = await service.loadEntry(date);

        expect(loaded, isNotNull);
        expect(loaded!.mood, equals(Mood.happy));
        expect(loaded.strokes.length, equals(1));
        expect(loaded.stickers.length, equals(1));
        expect(loaded.texts.length, equals(1));
        expect(loaded.weather, isNotNull);
      });

      test('should update existing entry', () async {
        final date = DateTime(2024, 1, 15);
        const entry1 = JournalEntry(mood: Mood.happy);
        const entry2 = JournalEntry(mood: Mood.sad);

        await service.saveEntry(date, entry1);
        await service.saveEntry(date, entry2);

        final loaded = await service.loadEntry(date);
        expect(loaded, isNotNull);
        expect(loaded!.mood, equals(Mood.sad));
      });

      test('should normalize date to remove time component', () async {
        final date1 = DateTime(2024, 1, 15, 10, 30, 45);
        final date2 = DateTime(2024, 1, 15, 20, 15, 30);
        const entry = JournalEntry(mood: Mood.happy);

        await service.saveEntry(date1, entry);
        final loaded = await service.loadEntry(date2);

        expect(loaded, isNotNull);
        expect(loaded!.mood, equals(Mood.happy));
      });
    });

    group('Load All Entries', () {
      test('should return empty map when no entries exist', () async {
        final entries = await service.loadAllEntries();
        expect(entries, isEmpty);
      });

      test('should load all saved entries', () async {
        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2024, 1, 16);
        final date3 = DateTime(2024, 1, 17);

        await service.saveEntry(date1, const JournalEntry(mood: Mood.happy));
        await service.saveEntry(date2, const JournalEntry(mood: Mood.sad));
        await service.saveEntry(date3, const JournalEntry(mood: Mood.neutral));

        final entries = await service.loadAllEntries();

        expect(entries.length, equals(3));
        expect(entries[DateTime(2024, 1, 15)]?.mood, equals(Mood.happy));
        expect(entries[DateTime(2024, 1, 16)]?.mood, equals(Mood.sad));
        expect(entries[DateTime(2024, 1, 17)]?.mood, equals(Mood.neutral));
      });

      test('should handle entries with different dates', () async {
        final dates = [
          DateTime(2024, 1, 15),
          DateTime(2024, 2, 20),
          DateTime(2023, 12, 25),
        ];

        for (var i = 0; i < dates.length; i++) {
          await service.saveEntry(
            dates[i],
            JournalEntry(mood: Mood.values[i % Mood.values.length]),
          );
        }

        final entries = await service.loadAllEntries();
        expect(entries.length, equals(3));
      });
    });

    group('Delete Entry', () {
      test('should delete existing entry', () async {
        final date = DateTime(2024, 1, 15);
        const entry = JournalEntry(mood: Mood.happy);

        await service.saveEntry(date, entry);
        await service.deleteEntry(date);

        final loaded = await service.loadEntry(date);
        expect(loaded, isNull);
      });

      test('should not throw error when deleting non-existent entry', () async {
        final date = DateTime(2024, 1, 15);
        await service.deleteEntry(date);
        // Should not throw
      });

      test('should delete only specified entry', () async {
        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2024, 1, 16);

        await service.saveEntry(date1, const JournalEntry(mood: Mood.happy));
        await service.saveEntry(date2, const JournalEntry(mood: Mood.sad));

        await service.deleteEntry(date1);

        expect(await service.loadEntry(date1), isNull);
        expect(await service.loadEntry(date2), isNotNull);
      });
    });
  });
}

