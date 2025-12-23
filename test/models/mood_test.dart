import 'package:flutter_test/flutter_test.dart';
import 'package:mochi/models/mood.dart';

void main() {
  group('Mood', () {
    test('should have three mood values', () {
      expect(Mood.values.length, equals(3));
    });

    test('should have happy, neutral, and sad moods', () {
      expect(Mood.values, contains(Mood.happy));
      expect(Mood.values, contains(Mood.neutral));
      expect(Mood.values, contains(Mood.sad));
    });

    test('should have correct enum names', () {
      expect(Mood.happy.name, equals('happy'));
      expect(Mood.neutral.name, equals('neutral'));
      expect(Mood.sad.name, equals('sad'));
    });

    test('should be able to find mood by name', () {
      expect(Mood.values.firstWhere((m) => m.name == 'happy'), equals(Mood.happy));
      expect(Mood.values.firstWhere((m) => m.name == 'neutral'), equals(Mood.neutral));
      expect(Mood.values.firstWhere((m) => m.name == 'sad'), equals(Mood.sad));
    });
  });
}

