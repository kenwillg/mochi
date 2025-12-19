import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/journal_entry.dart';
import '../providers/journal_providers.dart';
import '../utils/constants.dart';
import '../widgets/daily_details_card.dart';
import 'journal_entry_screen.dart';

// --- MONTH VIEW SCREEN (Shows calendar for a specific month) ---
class MonthViewScreen extends ConsumerStatefulWidget {
  const MonthViewScreen({super.key});

  static const routeName = '/month';

  @override
  ConsumerState<MonthViewScreen> createState() => _MonthViewScreenState();
}

class _MonthViewScreenState extends ConsumerState<MonthViewScreen> {
  DateTime? _lastTappedDay;
  DateTime? _lastTapTimestamp;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is MonthViewScreenArguments) {
        setState(() {
          _focusedDay = DateTime(args.year, args.month, 1);
          _selectedDay = _focusedDay;
        });
      }
      _initialized = true;
    }
  }

  Future<void> _openEntryDialog(DateTime date) async {
    final bool? entryWasSaved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding: const EdgeInsets.all(0),
          content: DailyDetailsCard(date: date),
        );
      },
    );

    if (entryWasSaved == true && context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Success!"),
          content: const Text("Your Mochi entry has been saved."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  bool _entryHasContent(JournalEntry? entry) {
    if (entry == null) {
      return false;
    }
    return entry.mood != null ||
        entry.strokes.isNotEmpty ||
        entry.stickers.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is! MonthViewScreenArguments) {
      return const Scaffold(
        body: Center(child: Text('Invalid arguments')),
      );
    }

    final journalData = ref.watch(journalProvider);
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('${monthNames[args.month - 1]} ${args.year}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEntryDialog(_selectedDay),
        backgroundColor: accentColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (newSelectedDay, newFocusedDay) async {
              setState(() {
                _selectedDay = newSelectedDay;
                _focusedDay = newFocusedDay;
              });

              final now = DateTime.now();
              final isDoubleTap = _lastTappedDay != null &&
                  isSameDay(_lastTappedDay, newSelectedDay) &&
                  _lastTapTimestamp != null &&
                  now.difference(_lastTapTimestamp!) <
                      const Duration(milliseconds: 500);

              _lastTappedDay = newSelectedDay;
              _lastTapTimestamp = now;

              if (isDoubleTap) {
                final dateKey = DateTime(
                  newSelectedDay.year,
                  newSelectedDay.month,
                  newSelectedDay.day,
                );
                final entry = ref.read(journalProvider)[dateKey];
                if (_entryHasContent(entry)) {
                  await Navigator.of(context).pushNamed(
                    JournalEntryScreen.routeName,
                    arguments: JournalEntryScreenArguments(date: dateKey),
                  );
                } else {
                  await _openEntryDialog(dateKey);
                }
              }
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                final dayOnly = DateTime(date.year, date.month, date.day);
                final JournalEntry? entry = journalData[dayOnly];
                if (entry != null &&
                    (entry.mood != null ||
                        entry.strokes.isNotEmpty ||
                        entry.stickers.isNotEmpty)) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: GoogleFonts.patrickHand(fontSize: 20.0),
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: accentColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MonthViewScreenArguments {
  final int year;
  final int month;

  MonthViewScreenArguments({required this.year, required this.month});
}

