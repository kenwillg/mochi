import 'dart:ui';

import 'mood.dart';

class DrawnStroke {
  const DrawnStroke({required this.points});

  final List<Offset> points;

  DrawnStroke copyWith({List<Offset>? points}) {
    return DrawnStroke(points: points ?? List.of(this.points));
  }
}

class StickerPlacement {
  const StickerPlacement({
    required this.mood,
    required this.position,
    this.size = 72,
  });

  final Mood mood;
  final Offset position;
  final double size;

  StickerPlacement copyWith({Mood? mood, Offset? position, double? size}) {
    return StickerPlacement(
      mood: mood ?? this.mood,
      position: position ?? this.position,
      size: size ?? this.size,
    );
  }
}

class JournalEntry {
  const JournalEntry({
    this.mood,
    this.strokes = const [],
    this.stickers = const [],
  });

  final Mood? mood;
  final List<DrawnStroke> strokes;
  final List<StickerPlacement> stickers;

  JournalEntry copyWith({
    Mood? mood,
    List<DrawnStroke>? strokes,
    List<StickerPlacement>? stickers,
  }) {
    return JournalEntry(
      mood: mood ?? this.mood,
      strokes: strokes ?? List.of(this.strokes),
      stickers: stickers ?? List.of(this.stickers),
    );
  }
}
