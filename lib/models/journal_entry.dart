import 'dart:ui';

import 'package:flutter/material.dart';

import 'mood.dart';

class DrawnStroke {
  const DrawnStroke({required this.points, this.color = Colors.black87});

  final List<Offset> points;
  final Color color;

  DrawnStroke copyWith({List<Offset>? points, Color? color}) {
    return DrawnStroke(
      points: points ?? List.of(this.points),
      color: color ?? this.color,
    );
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

class TextPlacement {
  const TextPlacement({
    required this.text,
    required this.position,
    this.color = Colors.black87,
    this.fontSize = 16.0,
  });

  final String text;
  final Offset position;
  final Color color;
  final double fontSize;

  TextPlacement copyWith({
    String? text,
    Offset? position,
    Color? color,
    double? fontSize,
  }) {
    return TextPlacement(
      text: text ?? this.text,
      position: position ?? this.position,
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}

class JournalEntry {
  const JournalEntry({
    this.mood,
    this.strokes = const [],
    this.stickers = const [],
    this.texts = const [],
  });

  final Mood? mood;
  final List<DrawnStroke> strokes;
  final List<StickerPlacement> stickers;
  final List<TextPlacement> texts;

  JournalEntry copyWith({
    Mood? mood,
    List<DrawnStroke>? strokes,
    List<StickerPlacement>? stickers,
    List<TextPlacement>? texts,
  }) {
    return JournalEntry(
      mood: mood ?? this.mood,
      strokes: strokes ?? List.of(this.strokes),
      stickers: stickers ?? List.of(this.stickers),
      texts: texts ?? List.of(this.texts),
    );
  }
}
