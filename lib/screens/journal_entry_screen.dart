import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/rendering.dart';

import '../models/journal_entry.dart';
import '../models/mood.dart';
import '../providers/journal_providers.dart';
import '../utils/constants.dart';

class JournalEntryScreenArguments {
  const JournalEntryScreenArguments({required this.date});

  final DateTime date;
}

class JournalEntryScreen extends ConsumerStatefulWidget {
  const JournalEntryScreen({super.key, required this.date});

  static const routeName = '/journal-entry';

  final DateTime date;

  @override
  ConsumerState<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends ConsumerState<JournalEntryScreen> {
  final GlobalKey _canvasKey = GlobalKey();
  final List<DrawnStroke> _strokes = [];
  final List<StickerPlacement> _stickers = [];
  int? _selectedStickerIndex;

  @override
  void initState() {
    super.initState();
    final entry = ref
        .read(journalProvider.notifier)
        .entryFor(widget.date);
    _strokes
      ..clear()
      ..addAll(entry.strokes
          .map((stroke) => DrawnStroke(points: List.of(stroke.points))));
    _stickers
      ..clear()
      ..addAll(entry.stickers
          .map((sticker) =>
              StickerPlacement(mood: sticker.mood, position: sticker.position, size: sticker.size)));
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _selectedStickerIndex = null;
      _strokes.add(DrawnStroke(points: [details.localPosition]));
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_strokes.isEmpty) {
      return;
    }
    setState(() {
      final points = _strokes.last.points;
      points.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_strokes.isEmpty) {
      return;
    }
    final cleaned = _strokes.last.points
        .map((point) => Offset(point.dx, point.dy))
        .toList();
    setState(() {
      _strokes[_strokes.length - 1] = DrawnStroke(points: cleaned);
    });
  }

  void _addSticker(Mood mood) {
    const defaultSize = 72.0;
    final renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    final size = renderBox?.size;
    final position = size == null
        ? const Offset(180, 220)
        : Offset(size.width / 2, size.height / 2);
    setState(() {
      _stickers.add(
        StickerPlacement(
          mood: mood,
          position: position,
          size: defaultSize,
        ),
      );
      _selectedStickerIndex = _stickers.length - 1;
    });
  }

  void _saveEntry() {
    ref.read(journalProvider.notifier).updateCanvas(
          widget.date,
          strokes: _strokes
              .map((stroke) =>
                  DrawnStroke(points: stroke.points.map((e) => Offset(e.dx, e.dy)).toList()))
              .toList(),
          stickers: _stickers
              .map((sticker) => StickerPlacement(
                    mood: sticker.mood,
                    position: Offset(sticker.position.dx, sticker.position.dy),
                    size: sticker.size,
                  ))
              .toList(),
        );
    Navigator.of(context).pop();
  }

  void _showStickerPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: _stickerIcon(Mood.happy, size: 32),
                title: const Text('Add happy sticker'),
                onTap: () {
                  Navigator.of(context).pop();
                  _addSticker(Mood.happy);
                },
              ),
              ListTile(
                leading: _stickerIcon(Mood.neutral, size: 32),
                title: const Text('Add neutral sticker'),
                onTap: () {
                  Navigator.of(context).pop();
                  _addSticker(Mood.neutral);
                },
              ),
              ListTile(
                leading: _stickerIcon(Mood.sad, size: 32),
                title: const Text('Add sad sticker'),
                onTap: () {
                  Navigator.of(context).pop();
                  _addSticker(Mood.sad);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _stickerIcon(Mood mood, {double size = 48}) {
    final icon = mood == Mood.happy
        ? Icons.sentiment_very_satisfied
        : mood == Mood.neutral
            ? Icons.sentiment_neutral
            : Icons.sentiment_very_dissatisfied;
    return Icon(icon, size: size, color: primaryColor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal entry'),
        actions: [
          TextButton(
            onPressed: _saveEntry,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Draw how you felt today. Tap + to add stickers!',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                onTap: () => setState(() => _selectedStickerIndex = null),
                child: Container(
                  key: _canvasKey,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      CustomPaint(
                        painter: _JournalCanvasPainter(strokes: _strokes),
                        size: Size.infinite,
                      ),
                      ..._buildStickerWidgets(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showStickerPicker,
        backgroundColor: accentColor,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  List<Widget> _buildStickerWidgets() {
    final List<Widget> widgets = [];
    for (var i = 0; i < _stickers.length; i++) {
      final sticker = _stickers[i];
      final selected = i == _selectedStickerIndex;
      final double halfSize = sticker.size / 2;
      widgets.add(
        Positioned(
          left: sticker.position.dx - halfSize,
          top: sticker.position.dy - halfSize,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedStickerIndex = selected ? null : i;
              });
            },
            onPanUpdate: selected
                ? (details) {
                    setState(() {
                      _stickers[i] = _stickers[i].copyWith(
                        position: _stickers[i].position + details.delta,
                      );
                    });
                  }
                : null,
            child: Container(
              width: sticker.size,
              height: sticker.size,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                border: Border.all(
                  color: selected ? accentColor : Colors.transparent,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: _stickerIcon(sticker.mood, size: sticker.size * 0.65),
            ),
          ),
        ),
      );
    }
    return widgets;
  }
}

class _JournalCanvasPainter extends CustomPainter {
  _JournalCanvasPainter({required this.strokes});

  final List<DrawnStroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.points.length < 2) {
        if (stroke.points.isNotEmpty) {
          canvas.drawPoints(PointMode.points, stroke.points, paint);
        }
        continue;
      }
      final path = Path()..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (var i = 1; i < stroke.points.length; i++) {
        final point = stroke.points[i];
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _JournalCanvasPainter oldDelegate) {
    return true;
  }
}
