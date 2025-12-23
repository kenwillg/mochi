import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mochi/models/journal_entry.dart';
import 'package:mochi/models/mood.dart';
import 'package:mochi/models/weather_info.dart';

void main() {
  group('DrawnStroke', () {
    test('should create DrawnStroke with default color', () {
      final points = [const Offset(10, 20), const Offset(30, 40)];
      final stroke = DrawnStroke(points: points);

      expect(stroke.points, equals(points));
      expect(stroke.color, equals(Colors.black87));
    });

    test('should create DrawnStroke with custom color', () {
      final points = [const Offset(10, 20)];
      final color = Colors.red;
      final stroke = DrawnStroke(points: points, color: color);

      expect(stroke.points, equals(points));
      expect(stroke.color, equals(color));
    });

    test('copyWith should create new instance with updated values', () {
      final original = DrawnStroke(
        points: [const Offset(10, 20)],
        color: Colors.blue,
      );
      final updated = original.copyWith(
        points: [const Offset(50, 60)],
        color: Colors.green,
      );

      expect(updated.points, equals([const Offset(50, 60)]));
      expect(updated.color, equals(Colors.green));
      expect(original.points, equals([const Offset(10, 20)])); // Original unchanged
    });

    test('copyWith should preserve original values when null', () {
      final original = DrawnStroke(
        points: [const Offset(10, 20)],
        color: Colors.blue,
      );
      final updated = original.copyWith();

      expect(updated.points, equals(original.points));
      expect(updated.color, equals(original.color));
    });
  });

  group('StickerPlacement', () {
    test('should create StickerPlacement with default size', () {
      const placement = StickerPlacement(
        mood: Mood.happy,
        position: Offset(100, 200),
      );

      expect(placement.mood, equals(Mood.happy));
      expect(placement.position, equals(const Offset(100, 200)));
      expect(placement.size, equals(72));
    });

    test('should create StickerPlacement with custom size', () {
      const placement = StickerPlacement(
        mood: Mood.sad,
        position: Offset(50, 75),
        size: 100,
      );

      expect(placement.mood, equals(Mood.sad));
      expect(placement.position, equals(const Offset(50, 75)));
      expect(placement.size, equals(100));
    });

    test('copyWith should create new instance with updated values', () {
      const original = StickerPlacement(
        mood: Mood.happy,
        position: Offset(10, 20),
        size: 72,
      );
      final updated = original.copyWith(
        mood: Mood.neutral,
        position: const Offset(30, 40),
        size: 100,
      );

      expect(updated.mood, equals(Mood.neutral));
      expect(updated.position, equals(const Offset(30, 40)));
      expect(updated.size, equals(100));
    });
  });

  group('TextPlacement', () {
    test('should create TextPlacement with default values', () {
      const placement = TextPlacement(
        text: 'Hello',
        position: Offset(100, 200),
      );

      expect(placement.text, equals('Hello'));
      expect(placement.position, equals(const Offset(100, 200)));
      expect(placement.color, equals(Colors.black87));
      expect(placement.fontSize, equals(16.0));
    });

    test('should create TextPlacement with custom values', () {
      const placement = TextPlacement(
        text: 'Test',
        position: Offset(50, 75),
        color: Colors.red,
        fontSize: 24.0,
      );

      expect(placement.text, equals('Test'));
      expect(placement.position, equals(const Offset(50, 75)));
      expect(placement.color, equals(Colors.red));
      expect(placement.fontSize, equals(24.0));
    });

    test('copyWith should create new instance with updated values', () {
      const original = TextPlacement(
        text: 'Original',
        position: Offset(10, 20),
        color: Colors.blue,
        fontSize: 16.0,
      );
      final updated = original.copyWith(
        text: 'Updated',
        position: const Offset(30, 40),
        color: Colors.green,
        fontSize: 20.0,
      );

      expect(updated.text, equals('Updated'));
      expect(updated.position, equals(const Offset(30, 40)));
      expect(updated.color, equals(Colors.green));
      expect(updated.fontSize, equals(20.0));
    });
  });

  group('JournalEntry', () {
    test('should create empty JournalEntry', () {
      const entry = JournalEntry();

      expect(entry.mood, isNull);
      expect(entry.strokes, isEmpty);
      expect(entry.stickers, isEmpty);
      expect(entry.texts, isEmpty);
      expect(entry.weather, isNull);
    });

    test('should create JournalEntry with mood', () {
      const entry = JournalEntry(mood: Mood.happy);

      expect(entry.mood, equals(Mood.happy));
      expect(entry.strokes, isEmpty);
    });

    test('should create JournalEntry with strokes', () {
      final strokes = [
        DrawnStroke(points: [const Offset(10, 20)]),
        DrawnStroke(points: [const Offset(30, 40)], color: Colors.red),
      ];

      // Test with actual strokes
      final entryWithStrokes = JournalEntry(strokes: strokes);
      expect(entryWithStrokes.strokes.length, equals(2));
    });

    test('should create JournalEntry with stickers', () {
      const stickers = [
        StickerPlacement(mood: Mood.happy, position: Offset(10, 20)),
        StickerPlacement(mood: Mood.sad, position: Offset(30, 40)),
      ];
      const entry = JournalEntry(stickers: stickers);

      expect(entry.stickers.length, equals(2));
      expect(entry.stickers[0].mood, equals(Mood.happy));
      expect(entry.stickers[1].mood, equals(Mood.sad));
    });

    test('should create JournalEntry with texts', () {
      const texts = [
        TextPlacement(text: 'Hello', position: Offset(10, 20)),
        TextPlacement(text: 'World', position: Offset(30, 40)),
      ];
      const entry = JournalEntry(texts: texts);

      expect(entry.texts.length, equals(2));
      expect(entry.texts[0].text, equals('Hello'));
      expect(entry.texts[1].text, equals('World'));
    });

    test('should create JournalEntry with weather', () {
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
      final entry = JournalEntry(weather: weather);

      expect(entry.weather, isNotNull);
      expect(entry.weather!.locationName, equals('Jakarta'));
      expect(entry.weather!.temperatureC, equals(30.0));
    });

    test('copyWith should create new instance with updated mood', () {
      const original = JournalEntry(mood: Mood.happy);
      final updated = original.copyWith(mood: Mood.sad);

      expect(updated.mood, equals(Mood.sad));
      expect(original.mood, equals(Mood.happy)); // Original unchanged
    });

    test('copyWith should preserve original values when null', () {
      const original = JournalEntry(
        mood: Mood.happy,
        strokes: [],
        stickers: [],
        texts: [],
      );
      final updated = original.copyWith();

      expect(updated.mood, equals(original.mood));
      expect(updated.strokes, equals(original.strokes));
    });

    test('copyWith should update strokes', () {
      const original = JournalEntry(strokes: []);
      final newStrokes = [
        DrawnStroke(points: [const Offset(10, 20)]),
      ];
      final updated = original.copyWith(strokes: newStrokes);

      expect(updated.strokes.length, equals(1));
      expect(original.strokes, isEmpty); // Original unchanged
    });
  });
}

