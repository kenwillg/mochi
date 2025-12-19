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

enum _ToolMode { draw, text, sticker }

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
  final List<TextPlacement> _texts = [];
  int? _selectedStickerIndex;
  int? _selectedTextIndex;
  _ToolMode _currentMode = _ToolMode.draw;
  Color _currentColor = Colors.black87;
  final TextEditingController _textController = TextEditingController();

  // Available colors for drawing and text
  static const List<Color> _availableColors = [
    Colors.black87,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.teal,
    Colors.indigo,
    Colors.cyan,
    Colors.amber,
    Colors.deepOrange,
    Colors.lightBlue,
    Colors.lime,
  ];

  @override
  void initState() {
    super.initState();
    final entry = ref.read(journalProvider.notifier).entryFor(widget.date);
    _strokes
      ..clear()
      ..addAll(
        entry.strokes.map(
          (stroke) =>
              DrawnStroke(points: List.of(stroke.points), color: stroke.color),
        ),
      );
    _stickers
      ..clear()
      ..addAll(
        entry.stickers.map(
          (sticker) => StickerPlacement(
            mood: sticker.mood,
            position: sticker.position,
            size: sticker.size,
          ),
        ),
      );
    _texts
      ..clear()
      ..addAll(entry.texts);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (_currentMode != _ToolMode.draw) return;
    if (!_isPointInsideCanvas(details.localPosition)) {
      return;
    }
    final clampedPosition = _clampToCanvas(details.localPosition);
    setState(() {
      _selectedStickerIndex = null;
      _selectedTextIndex = null;
      _strokes.add(
        DrawnStroke(points: [clampedPosition], color: _currentColor),
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_currentMode != _ToolMode.draw) return;
    if (_strokes.isEmpty) {
      return;
    }
    final clampedPosition = _clampToCanvas(details.localPosition);
    setState(() {
      final points = _strokes.last.points;
      points.add(clampedPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentMode != _ToolMode.draw) return;
    if (_strokes.isEmpty) {
      return;
    }
    final cleaned = _strokes.last.points
        .map((point) => Offset(point.dx, point.dy))
        .toList();
    setState(() {
      _strokes[_strokes.length - 1] = _strokes[_strokes.length - 1].copyWith(
        points: cleaned,
      );
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
        StickerPlacement(mood: mood, position: position, size: defaultSize),
      );
      _selectedStickerIndex = _stickers.length - 1;
      _selectedTextIndex = null;
      _currentMode = _ToolMode.sticker;
    });
  }

  void _addText(Offset position) {
    _textController.clear();
    showDialog(
      context: context,
      builder: (context) {
        double fontSize = 16.0;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Add Text'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _textController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Enter your text...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    maxLines: 3,
                    style: TextStyle(color: _currentColor, fontSize: fontSize),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Size:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Slider(
                          value: fontSize,
                          min: 12.0,
                          max: 32.0,
                          divisions: 10,
                          label: fontSize.round().toString(),
                          onChanged: (value) {
                            setDialogState(() {
                              fontSize = value;
                            });
                          },
                        ),
                      ),
                      Text(
                        fontSize.round().toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      setState(() {
                        _texts.add(
                          TextPlacement(
                            text: _textController.text,
                            position: position,
                            color: _currentColor,
                            fontSize: fontSize,
                          ),
                        );
                        _selectedTextIndex = _texts.length - 1;
                        _selectedStickerIndex = null;
                      });
                    }
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editText(int index) {
    final text = _texts[index];
    _textController.text = text.text;
    _currentColor = text.color;
    showDialog(
      context: context,
      builder: (context) {
        double fontSize = text.fontSize;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Edit Text'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _textController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Enter your text...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    maxLines: 3,
                    style: TextStyle(color: _currentColor, fontSize: fontSize),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Size:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Slider(
                          value: fontSize,
                          min: 12.0,
                          max: 32.0,
                          divisions: 10,
                          label: fontSize.round().toString(),
                          onChanged: (value) {
                            setDialogState(() {
                              fontSize = value;
                            });
                          },
                        ),
                      ),
                      Text(
                        fontSize.round().toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _texts.removeAt(index);
                      _selectedTextIndex = null;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      setState(() {
                        _texts[index] = text.copyWith(
                          text: _textController.text,
                          color: _currentColor,
                          fontSize: fontSize,
                        );
                      });
                    }
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onCanvasTap(TapDownDetails details) {
    if (_currentMode == _ToolMode.text) {
      final position = _clampToCanvas(details.localPosition);
      _addText(position);
    } else {
      setState(() {
        _selectedStickerIndex = null;
        _selectedTextIndex = null;
      });
    }
  }

  void _saveEntry() {
    ref
        .read(journalProvider.notifier)
        .updateCanvas(
          widget.date,
          strokes: _strokes
              .map(
                (stroke) => DrawnStroke(
                  points: stroke.points.map((e) => Offset(e.dx, e.dy)).toList(),
                  color: stroke.color,
                ),
              )
              .toList(),
          stickers: _stickers
              .map(
                (sticker) => StickerPlacement(
                  mood: sticker.mood,
                  position: Offset(sticker.position.dx, sticker.position.dy),
                  size: sticker.size,
                ),
              )
              .toList(),
          texts: _texts
              .map(
                (text) => TextPlacement(
                  text: text.text,
                  position: Offset(text.position.dx, text.position.dy),
                  color: text.color,
                  fontSize: text.fontSize,
                ),
              )
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
        actions: [TextButton(onPressed: _saveEntry, child: const Text('Save'))],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tool selection bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildToolButton(
                    icon: Icons.edit,
                    label: 'Draw',
                    mode: _ToolMode.draw,
                  ),
                  _buildToolButton(
                    icon: Icons.text_fields,
                    label: 'Text',
                    mode: _ToolMode.text,
                  ),
                  _buildToolButton(
                    icon: Icons.emoji_emotions,
                    label: 'Sticker',
                    mode: _ToolMode.sticker,
                  ),
                ],
              ),
            ),
            // Enhanced color picker (shown when in draw or text mode)
            if (_currentMode == _ToolMode.draw ||
                _currentMode == _ToolMode.text)
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Select Color',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: _availableColors.map((color) {
                        final isSelected = color == _currentColor;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentColor = color;
                              // Update selected text color if in text mode
                              if (_currentMode == _ToolMode.text &&
                                  _selectedTextIndex != null) {
                                _texts[_selectedTextIndex!] =
                                    _texts[_selectedTextIndex!].copyWith(
                                      color: color,
                                    );
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: isSelected ? 40 : 36,
                            height: isSelected ? 40 : 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? accentColor
                                    : Colors.grey.shade300,
                                width: isSelected ? 3 : 2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withOpacity(0.4),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                onTapDown: _onCanvasTap,
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
                      ..._buildTextWidgets(),
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
      floatingActionButton: _currentMode == _ToolMode.sticker
          ? FloatingActionButton(
              onPressed: _showStickerPicker,
              backgroundColor: accentColor,
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required _ToolMode mode,
  }) {
    final isSelected = _currentMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentMode = mode;
          if (mode == _ToolMode.sticker) {
            _selectedStickerIndex = null;
            _selectedTextIndex = null;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? accentColor : Colors.grey, size: 20),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? accentColor : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTextWidgets() {
    final List<Widget> widgets = [];
    for (var i = 0; i < _texts.length; i++) {
      final text = _texts[i];
      final selected = i == _selectedTextIndex;
      widgets.add(
        Positioned(
          left: text.position.dx,
          top: text.position.dy,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedTextIndex = selected ? null : i;
                _selectedStickerIndex = null;
                if (!selected) {
                  _currentMode = _ToolMode.text;
                }
              });
            },
            onDoubleTap: () {
              _editText(i);
            },
            onPanUpdate: selected
                ? (details) {
                    setState(() {
                      _texts[i] = _texts[i].copyWith(
                        position: _texts[i].position + details.delta,
                      );
                    });
                  }
                : null,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? text.color.withOpacity(0.1)
                        : Colors.transparent,
                    border: selected
                        ? Border.all(color: accentColor, width: 2)
                        : null,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    text.text,
                    style: TextStyle(
                      color: text.color,
                      fontSize: text.fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Edit button (shown when selected)
                if (selected)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: GestureDetector(
                      onTap: () => _editText(i),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }
    return widgets;
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
                _selectedTextIndex = null;
                _currentMode = _ToolMode.sticker;
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
            child: Stack(
              children: [
                Container(
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
                // Resize handles (shown when selected)
                if (selected) ..._buildResizeHandles(i),
              ],
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  List<Widget> _buildResizeHandles(int stickerIndex) {
    final sticker = _stickers[stickerIndex];
    return [
      // Bottom-right resize handle
      Positioned(
        right: -12,
        bottom: -12,
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              // Calculate size change based on diagonal movement
              final delta = (details.delta.dx + details.delta.dy) / 2;
              final newSize = (sticker.size + delta).clamp(40.0, 200.0);
              _stickers[stickerIndex] = sticker.copyWith(size: newSize);
            });
          },
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              Icons.open_in_full,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ),
      // Top-left resize handle (for shrinking)
      Positioned(
        left: -12,
        top: -12,
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              // Calculate size change (opposite direction)
              final delta = -(details.delta.dx + details.delta.dy) / 2;
              final newSize = (sticker.size + delta).clamp(40.0, 200.0);
              _stickers[stickerIndex] = sticker.copyWith(size: newSize);
            });
          },
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              Icons.close_fullscreen,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ),
    ];
  }

  bool _isPointInsideCanvas(Offset position) {
    final renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return true;
    }
    final size = renderBox.size;
    return position.dx >= 0 &&
        position.dy >= 0 &&
        position.dx <= size.width &&
        position.dy <= size.height;
  }

  Offset _clampToCanvas(Offset position) {
    final renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return position;
    }
    final size = renderBox.size;
    final clampedDx = position.dx.clamp(0.0, size.width);
    final clampedDy = position.dy.clamp(0.0, size.height);
    return Offset(clampedDx, clampedDy);
  }
}

class _JournalCanvasPainter extends CustomPainter {
  _JournalCanvasPainter({required this.strokes});

  final List<DrawnStroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (stroke.points.length < 2) {
        if (stroke.points.isNotEmpty) {
          canvas.drawPoints(PointMode.points, stroke.points, paint);
        }
        continue;
      }
      final path = Path()
        ..moveTo(stroke.points.first.dx, stroke.points.first.dy);
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
