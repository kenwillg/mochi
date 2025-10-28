import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // FIX: Corrected package import path

import 'screens/demo_menu_screen.dart';
import 'screens/navigation_demo_screen.dart';
import 'screens/rest_workflow/rest_workflow_screen.dart';

// --- App Theme Colors ---
const Color primaryColor = Color(0xFF86A873);
const Color backgroundColor = Color(0xFFF7F7F2);
const Color accentColor = Color(0xFFF2A384);

// --- Data Models ---
enum Mood { happy, neutral, sad }

// --- Providers (Our App's "State") ---

// 1. THE "BRAIN" - This is our app's central database for moods.
class JournalDataNotifier extends StateNotifier<Map<DateTime, Mood?>> {
  JournalDataNotifier() : super({});

  void updateMood(DateTime date, Mood newMood) {
    // We create a new map so Riverpod knows to update the UI.
    state = {...state, date: newMood};
  }
}

final journalProvider =
    StateNotifierProvider<JournalDataNotifier, Map<DateTime, Mood?>>((ref) {
      return JournalDataNotifier();
    });

// 2. Holds the currently selected day on the calendar.
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// 3. Provider to handle the loading spinner state.
final isSavingProvider = StateProvider<bool>((ref) => false);

void main() {
  runApp(const ProviderScope(child: MochiApp()));
}

class MochiApp extends StatelessWidget {
  const MochiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mochi',
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        textTheme: GoogleFonts.patrickHandTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'PatrickHand',
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.black87),
        ),
      ),
      initialRoute: MochiHomePage.routeName,
      routes: {
        MochiHomePage.routeName: (context) => const MochiHomePage(),
        DemoMenuScreen.routeName: (context) => const DemoMenuScreen(),
        NavigationDemoScreen.routeName: (context) => const NavigationDemoScreen(),
        RestWorkflowScreen.routeName: (context) => const RestWorkflowScreen(),
      },
      onGenerateRoute: NavigationDemoScreen.onGenerateRoute,
    );
  }
}

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
                if (journalData.containsKey(dayOnly)) {
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

// --- THE REUSABLE DETAILS CARD (Used in the Dialog) ---
class DailyDetailsCard extends ConsumerWidget {
  final DateTime date; // The card now knows which date it is working on.

  const DailyDetailsCard({required this.date, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // To properly check our map, we must ignore the time part of the date.
    final dateKey = DateTime(date.year, date.month, date.day);

    final journalData = ref.watch(journalProvider);
    final selectedMood = journalData[dateKey]; // Look up using the dateKey
    final isSaving = ref.watch(isSavingProvider);
    final formattedDate = DateFormat.yMMMMd().format(date);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Makes the card fit its content
        children: [
          Text(
            formattedDate, // Show the date this entry is for
            style: GoogleFonts.patrickHand(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final mood
                  in Mood.values) // A clean way to create all 3 chips
                ChoiceChip(
                  label: Text(mood.name),
                  avatar: Icon(
                    mood == Mood.happy
                        ? Icons.sentiment_very_satisfied
                        : mood == Mood.neutral
                        ? Icons.sentiment_neutral
                        : Icons.sentiment_very_dissatisfied,
                  ),
                  selected: selectedMood == mood,
                  onSelected: (isSelected) {
                    if (isSelected) {
                      ref
                          .read(journalProvider.notifier)
                          .updateMood(dateKey, mood);
                    }
                  },
                  selectedColor: primaryColor.withOpacity(0.7),
                ),
            ],
          ),
          const Divider(height: 30),
          // --- Placeholder for Image remains the same ---
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey.shade300,
                style: BorderStyle.solid,
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: Colors.grey),
                  SizedBox(height: 4),
                  Text("Add a photo", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () async {
                ref.read(isSavingProvider.notifier).state = true;
                await Future.delayed(const Duration(seconds: 2));
                ref.read(isSavingProvider.notifier).state = false;

                // FIX: Pop the dialog and return 'true' to signal success.
                if (context.mounted) {
                  Navigator.of(context).pop(true);
                }
              },
              child: isSaving
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : const Text("Save Entry", style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
