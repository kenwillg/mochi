import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/journal_entry.dart';
import '../models/mood.dart';
import '../providers/journal_providers.dart';
import '../utils/constants.dart';
import '../widgets/daily_details_card.dart';
import '../widgets/weather_icon_button.dart';
import 'bookshelf_screen.dart';
import 'demo_menu_screen.dart';
import 'stats_screen.dart';

// --- CALENDAR PAGE ---
class MochiHomePage extends ConsumerStatefulWidget {
  const MochiHomePage({super.key});

  static const routeName = '/';

  @override
  ConsumerState<MochiHomePage> createState() => _MochiHomePageState();
}

class _MochiHomePageState extends ConsumerState<MochiHomePage> {
  DateTime? _lastTappedDay;
  DateTime? _lastTapTimestamp;
  int _currentIndex = 0;
  bool _hasHandledArgs = false;

  @override
  void initState() {
    super.initState();
    // Initialize mock data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMockData();
      // Handle route arguments after the widget tree is built
      _handleRouteArguments();
    });
  }

  void _handleRouteArguments() {
    if (_hasHandledArgs) return;
    _hasHandledArgs = true;
    
    // Check if we have a year/month argument from bookshelf or year view navigation
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      Future.microtask(() {
        if (args.containsKey('year') && args.containsKey('month')) {
          final year = args['year'] as int;
          final month = args['month'] as int;
          ref.read(selectedDateProvider.notifier).setDate(DateTime(year, month, 1));
        } else if (args.containsKey('year')) {
          final year = args['year'] as int;
          ref.read(selectedDateProvider.notifier).setDate(DateTime(year, 1, 1));
        }
      });
    }
  }

  void _initializeMockData() {
    final now = DateTime.now();
    final journalData = ref.read(journalProvider);
    
    // Only add mock data if we have less than 5 entries (to avoid overwriting user data)
    if (journalData.length >= 5) return;
    
    final notifier = ref.read(journalProvider.notifier);
    
    // Add mock data for the last 30 days
    for (int i = 1; i <= 30; i++) {
      final date = now.subtract(Duration(days: i));
      final normalizedDate = DateTime(date.year, date.month, date.day);
      
      // Skip if entry already exists
      if (journalData[normalizedDate] != null) continue;
      
      // Random mood
      final moods = [Mood.happy, Mood.neutral, Mood.sad];
      final randomMood = moods[i % 3];
      
      // Create entry with mood
      notifier.updateMood(normalizedDate, randomMood);
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


  Future<void> _showMonthYearPicker(BuildContext context, DateTime focusedDay) async {
    final initialYear = focusedDay.year;
    final initialMonth = focusedDay.month;
    int? selectedYear;
    int? selectedMonth;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            selectedYear ??= initialYear;
            selectedMonth ??= initialMonth;

            return AlertDialog(
              title: Text(
                'Select Month & Year',
                style: GoogleFonts.patrickHand(fontSize: 20),
              ),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Month picker
                    Text(
                      'Month',
                      style: GoogleFonts.patrickHand(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 150,
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2.5,
                        ),
                        itemCount: 12,
                        itemBuilder: (context, index) {
                          final month = index + 1;
                          final monthNames = [
                            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                          ];
                          final isSelected = selectedMonth == month;
                          return InkWell(
                            onTap: () {
                              setDialogState(() {
                                selectedMonth = month;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primaryColor.withOpacity(0.2)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? primaryColor : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  monthNames[index],
                                  style: GoogleFonts.patrickHand(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? primaryColor : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Year picker
                    Text(
                      'Year',
                      style: GoogleFonts.patrickHand(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: YearPicker(
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        selectedDate: DateTime(selectedYear!),
                        onChanged: (date) {
                          setDialogState(() {
                            selectedYear = date.year;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedYear != null && selectedMonth != null) {
                      Navigator.of(context).pop({
                        'year': selectedYear,
                        'month': selectedMonth,
                      });
                    }
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    ).then((result) {
      if (result is Map && result.containsKey('year') && result.containsKey('month')) {
        final year = result['year'] as int;
        final month = result['month'] as int;
        ref.read(selectedDateProvider.notifier).setDate(DateTime(year, month, 1));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // We watch the selectedDateProvider to highlight the day on the calendar.
    final selectedDate = ref.watch(selectedDateProvider);
    final journalData = ref.watch(journalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Mochi Journal'),
        leading: IconButton(
          icon: const Icon(Icons.menu_book_rounded),
          tooltip: 'Open learning demos',
          onPressed: () {
            Navigator.of(context).pushNamed(DemoMenuScreen.routeName);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.library_books_rounded),
            tooltip: 'My Bookshelf',
            onPressed: () {
              Navigator.of(context).pushNamed(BookshelfScreen.routeName);
            },
          ),
          const WeatherIconButton(),
        ],
      ),
      // --- Floating Action Button for adding entries ---
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEntryDialog(selectedDate),
        backgroundColor: accentColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: selectedDate,
            selectedDayPredicate: (day) => isSameDay(selectedDate, day),
            onDaySelected: (newSelectedDay, newFocusedDay) async {
              ref.read(selectedDateProvider.notifier).setDate(newSelectedDay);

              final now = DateTime.now();
              final isDoubleTap =
                  _lastTappedDay != null &&
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
                // Always open the dialog - it will show view mode if mood is set, edit mode otherwise
                await _openEntryDialog(dateKey);
              }
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
              leftChevronIcon: const Icon(Icons.chevron_left),
              rightChevronIcon: const Icon(Icons.chevron_right),
            ),
            onHeaderTapped: (focusedDay) async {
              await _showMonthYearPicker(context, focusedDay);
            },
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey.shade400,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 1) {
            Navigator.of(context).pushNamed(StatsScreen.routeName);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}
