import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/journal_entry.dart';
import '../providers/journal_providers.dart';
import '../utils/constants.dart';
import '../widgets/daily_details_card.dart';
import 'demo_menu_screen.dart';

// --- CALENDAR PAGE ---
class MochiHomePage extends ConsumerWidget {
  const MochiHomePage({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      ),
      // --- Floating Action Button for adding entries ---
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // FIX: A safer way to handle dialogs.
          // We 'await' the result of the entry dialog.
          final bool? entryWasSaved = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                contentPadding: const EdgeInsets.all(0),
                content: DailyDetailsCard(date: selectedDate),
              );
            },
          );

          // If the entry was saved, we then show the success dialog.
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
        },
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
            onDaySelected: (newSelectedDay, newFocusedDay) {
              ref.read(selectedDateProvider.notifier).state = newSelectedDay;
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey.shade400,
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
