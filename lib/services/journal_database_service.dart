import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/journal_entry.dart';
import '../models/mood.dart';
import 'journal_storage_service.dart';

/// Service for managing journal entries in SQLite database
/// Provides debugging capabilities with detailed logging
class JournalDatabaseService implements JournalStorageService {
  static const String _databaseName = 'journal.db';
  static const int _databaseVersion = 1;
  static const String _tableName = 'journal_entries';

  Database? _database;

  /// Get or create database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    if (kDebugMode) {
      debugPrint('[JournalDatabase] Initializing database at: $path');
    }

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database schema
  Future<void> _onCreate(Database db, int version) async {
    if (kDebugMode) {
      debugPrint('[JournalDatabase] Creating table: $_tableName');
    }

    await db.execute('''
      CREATE TABLE $_tableName (
        date TEXT PRIMARY KEY,
        mood TEXT,
        strokes TEXT,
        stickers TEXT,
        texts TEXT,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    if (kDebugMode) {
      debugPrint('[JournalDatabase] Table created successfully');
    }
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (kDebugMode) {
      debugPrint(
        '[JournalDatabase] Upgrading database from version $oldVersion to $newVersion',
      );
    }
    // Add migration logic here if needed
  }

  /// Save journal entry to database
  @override
  Future<void> saveEntry(DateTime date, JournalEntry entry) async {
    try {
      final db = await database;
      final dateKey = _normalizeDate(date).toIso8601String().split('T')[0];
      final now = DateTime.now().millisecondsSinceEpoch;

      final moodStr = entry.mood?.name;
      final strokesJson = jsonEncode(
        entry.strokes
            .map(
              (s) => {
                'points': s.points
                    .map((p) => {'dx': p.dx, 'dy': p.dy})
                    .toList(),
                'color': s.color.value,
              },
            )
            .toList(),
      );
      final stickersJson = jsonEncode(
        entry.stickers
            .map(
              (s) => {
                'mood': s.mood.name,
                'position': {'dx': s.position.dx, 'dy': s.position.dy},
                'size': s.size,
              },
            )
            .toList(),
      );
      final textsJson = jsonEncode(
        entry.texts
            .map(
              (t) => {
                'text': t.text,
                'position': {'dx': t.position.dx, 'dy': t.position.dy},
                'color': t.color.value,
                'fontSize': t.fontSize,
              },
            )
            .toList(),
      );

      await db.insert(_tableName, {
        'date': dateKey,
        'mood': moodStr,
        'strokes': strokesJson,
        'stickers': stickersJson,
        'texts': textsJson,
        'created_at': now,
        'updated_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      if (kDebugMode) {
        debugPrint('[JournalDatabase] Saved entry for date: $dateKey');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[JournalDatabase] Error saving entry: $e');
      }
      rethrow;
    }
  }

  /// Load journal entry from database
  @override
  Future<JournalEntry?> loadEntry(DateTime date) async {
    try {
      final db = await database;
      final dateKey = _normalizeDate(date).toIso8601String().split('T')[0];

      final maps = await db.query(
        _tableName,
        where: 'date = ?',
        whereArgs: [dateKey],
      );

      if (maps.isEmpty) {
        if (kDebugMode) {
          debugPrint('[JournalDatabase] No entry found for date: $dateKey');
        }
        return null;
      }

      final map = maps.first;
      final moodStr = map['mood'] as String?;
      final strokesJson = map['strokes'] as String?;
      final stickersJson = map['stickers'] as String?;
      final textsJson = map['texts'] as String?;

      Mood? mood;
      if (moodStr != null) {
        mood = Mood.values.firstWhere(
          (m) => m.name == moodStr,
          orElse: () => Mood.neutral,
        );
      }

      List<DrawnStroke> strokes = [];
      if (strokesJson != null && strokesJson.isNotEmpty) {
        final strokesList = jsonDecode(strokesJson) as List;
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
      if (stickersJson != null && stickersJson.isNotEmpty) {
        final stickersList = jsonDecode(stickersJson) as List;
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
      if (textsJson != null && textsJson.isNotEmpty) {
        final textsList = jsonDecode(textsJson) as List;
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

      if (kDebugMode) {
        debugPrint('[JournalDatabase] Loaded entry for date: $dateKey');
      }

      return JournalEntry(
        mood: mood,
        strokes: strokes,
        stickers: stickers,
        texts: texts,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[JournalDatabase] Error loading entry: $e');
      }
      return null;
    }
  }

  /// Load all journal entries
  @override
  Future<Map<DateTime, JournalEntry>> loadAllEntries() async {
    try {
      final db = await database;
      final maps = await db.query(_tableName, orderBy: 'date DESC');

      final Map<DateTime, JournalEntry> entries = {};

      for (final map in maps) {
        final dateStr = map['date'] as String;
        final date = DateTime.parse(dateStr);
        final normalizedDate = _normalizeDate(date);

        final moodStr = map['mood'] as String?;
        final strokesJson = map['strokes'] as String?;
        final stickersJson = map['stickers'] as String?;
        final textsJson = map['texts'] as String?;

        Mood? mood;
        if (moodStr != null) {
          mood = Mood.values.firstWhere(
            (m) => m.name == moodStr,
            orElse: () => Mood.neutral,
          );
        }

        List<DrawnStroke> strokes = [];
        if (strokesJson != null && strokesJson.isNotEmpty) {
          final strokesList = jsonDecode(strokesJson) as List;
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
        if (stickersJson != null && stickersJson.isNotEmpty) {
          final stickersList = jsonDecode(stickersJson) as List;
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
        if (textsJson != null && textsJson.isNotEmpty) {
          final textsList = jsonDecode(textsJson) as List;
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

        entries[normalizedDate] = JournalEntry(
          mood: mood,
          strokes: strokes,
          stickers: stickers,
          texts: texts,
        );
      }

      if (kDebugMode) {
        debugPrint('[JournalDatabase] Loaded ${entries.length} entries');
      }

      return entries;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[JournalDatabase] Error loading all entries: $e');
      }
      return {};
    }
  }

  /// Delete journal entry
  @override
  Future<void> deleteEntry(DateTime date) async {
    try {
      final db = await database;
      final dateKey = _normalizeDate(date).toIso8601String().split('T')[0];

      await db.delete(_tableName, where: 'date = ?', whereArgs: [dateKey]);

      if (kDebugMode) {
        debugPrint('[JournalDatabase] Deleted entry for date: $dateKey');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[JournalDatabase] Error deleting entry: $e');
      }
      rethrow;
    }
  }

  /// Close database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      if (kDebugMode) {
        debugPrint('[JournalDatabase] Database closed');
      }
    }
  }

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
