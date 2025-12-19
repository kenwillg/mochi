import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/journal_entry.dart';
import '../models/mood.dart';

/// Platform-agnostic storage service for journal entries
/// Uses SharedPreferences on web, SQLite on mobile/desktop
abstract class JournalStorageService {
  Future<void> saveEntry(DateTime date, JournalEntry entry);
  Future<JournalEntry?> loadEntry(DateTime date);
  Future<Map<DateTime, JournalEntry>> loadAllEntries();
  Future<void> deleteEntry(DateTime date);
}

/// Web implementation using SharedPreferences
class WebJournalStorageService implements JournalStorageService {
  static const String _storageKey = 'journal_entries';
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  String _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day).toIso8601String().split('T')[0];

  @override
  Future<void> saveEntry(DateTime date, JournalEntry entry) async {
    try {
      final prefs = await _preferences;
      final dateKey = _normalizeDate(date);

      // Load all entries
      final allEntriesJson = prefs.getString(_storageKey);
      Map<String, dynamic> allEntries = {};
      if (allEntriesJson != null && allEntriesJson.isNotEmpty) {
        allEntries = jsonDecode(allEntriesJson) as Map<String, dynamic>;
      }

      // Serialize entry
      final entryJson = {
        'mood': entry.mood?.name,
        'strokes': entry.strokes.map((s) {
          return {
            'points': s.points.map((p) => {'dx': p.dx, 'dy': p.dy}).toList(),
            'color': s.color.value,
          };
        }).toList(),
        'stickers': entry.stickers.map((s) {
          return {
            'mood': s.mood.name,
            'position': {'dx': s.position.dx, 'dy': s.position.dy},
            'size': s.size,
          };
        }).toList(),
        'texts': entry.texts.map((t) {
          return {
            'text': t.text,
            'position': {'dx': t.position.dx, 'dy': t.position.dy},
            'color': t.color.value,
            'fontSize': t.fontSize,
          };
        }).toList(),
      };

      allEntries[dateKey] = entryJson;
      await prefs.setString(_storageKey, jsonEncode(allEntries));

      if (kDebugMode) {
        debugPrint('[WebJournalStorage] Saved entry for date: $dateKey');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[WebJournalStorage] Error saving entry: $e');
      }
      rethrow;
    }
  }

  @override
  Future<JournalEntry?> loadEntry(DateTime date) async {
    try {
      final prefs = await _preferences;
      final dateKey = _normalizeDate(date);

      final allEntriesJson = prefs.getString(_storageKey);
      if (allEntriesJson == null || allEntriesJson.isEmpty) {
        return null;
      }

      final allEntries = jsonDecode(allEntriesJson) as Map<String, dynamic>;
      final entryJson = allEntries[dateKey] as Map<String, dynamic>?;

      if (entryJson == null) {
        return null;
      }

      return _deserializeEntry(entryJson);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[WebJournalStorage] Error loading entry: $e');
      }
      return null;
    }
  }

  @override
  Future<Map<DateTime, JournalEntry>> loadAllEntries() async {
    try {
      final prefs = await _preferences;
      final allEntriesJson = prefs.getString(_storageKey);

      if (allEntriesJson == null || allEntriesJson.isEmpty) {
        return {};
      }

      final allEntries = jsonDecode(allEntriesJson) as Map<String, dynamic>;
      final Map<DateTime, JournalEntry> entries = {};

      for (final entry in allEntries.entries) {
        final date = DateTime.parse(entry.key);
        final normalizedDate = DateTime(date.year, date.month, date.day);
        final entryData = entry.value as Map<String, dynamic>;
        entries[normalizedDate] = _deserializeEntry(entryData);
      }

      if (kDebugMode) {
        debugPrint('[WebJournalStorage] Loaded ${entries.length} entries');
      }

      return entries;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[WebJournalStorage] Error loading all entries: $e');
      }
      return {};
    }
  }

  @override
  Future<void> deleteEntry(DateTime date) async {
    try {
      final prefs = await _preferences;
      final dateKey = _normalizeDate(date);

      final allEntriesJson = prefs.getString(_storageKey);
      if (allEntriesJson == null || allEntriesJson.isEmpty) {
        return;
      }

      final allEntries = jsonDecode(allEntriesJson) as Map<String, dynamic>;
      allEntries.remove(dateKey);
      await prefs.setString(_storageKey, jsonEncode(allEntries));

      if (kDebugMode) {
        debugPrint('[WebJournalStorage] Deleted entry for date: $dateKey');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[WebJournalStorage] Error deleting entry: $e');
      }
      rethrow;
    }
  }

  JournalEntry _deserializeEntry(Map<String, dynamic> entryJson) {
    Mood? mood;
    if (entryJson['mood'] != null) {
      mood = Mood.values.firstWhere(
        (m) => m.name == entryJson['mood'] as String,
        orElse: () => Mood.neutral,
      );
    }

    List<DrawnStroke> strokes = [];
    if (entryJson['strokes'] != null) {
      final strokesList = entryJson['strokes'] as List;
      strokes = strokesList.map((s) {
        final points = (s['points'] as List).map((p) {
          return Offset(p['dx'] as double, p['dy'] as double);
        }).toList();
        final colorValue = s['color'] as int?;
        final color = colorValue != null
            ? Color(colorValue)
            : Colors.black87; // Default color for backward compatibility
        return DrawnStroke(points: points, color: color);
      }).toList();
    }

    List<StickerPlacement> stickers = [];
    if (entryJson['stickers'] != null) {
      final stickersList = entryJson['stickers'] as List;
      stickers = stickersList.map((s) {
        final mood = Mood.values.firstWhere(
          (m) => m.name == s['mood'] as String,
          orElse: () => Mood.neutral,
        );
        final pos = s['position'] as Map;
        return StickerPlacement(
          mood: mood,
          position: Offset(pos['dx'] as double, pos['dy'] as double),
          size: (s['size'] as num).toDouble(),
        );
      }).toList();
    }

    List<TextPlacement> texts = [];
    if (entryJson['texts'] != null) {
      final textsList = entryJson['texts'] as List;
      texts = textsList.map((t) {
        final pos = t['position'] as Map;
        final colorValue = t['color'] as int?;
        final color = colorValue != null
            ? Color(colorValue)
            : Colors.black87; // Default color
        return TextPlacement(
          text: t['text'] as String,
          position: Offset(pos['dx'] as double, pos['dy'] as double),
          color: color,
          fontSize: (t['fontSize'] as num?)?.toDouble() ?? 16.0,
        );
      }).toList();
    }

    return JournalEntry(
      mood: mood,
      strokes: strokes,
      stickers: stickers,
      texts: texts,
    );
  }
}
