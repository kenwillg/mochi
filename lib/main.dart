import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

// --- App Theme Colors ---
// Using soft, friendly colors that match the "Mochi" theme.
const Color primaryColor = Color(0xFF86A873); // A soft, earthy green
const Color backgroundColor = Color(0xFFF7F7F2); // A gentle off-white
const Color accentColor = Color(0xFFF2A384); // A warm, peachy accent

void main() {
  runApp(const MochiApp());
}

class MochiApp extends StatelessWidget {
  const MochiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mochi',
      // --- Applying the App Theme ---
      // We define the overall look and feel, including our doodle-ish font.
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        // Using Google Fonts to get a friendly, handwritten style.
        textTheme: GoogleFonts.patrickHandTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent, // Make AppBar transparent
          elevation: 0, // Remove shadow
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
      home: const MochiHomePage(),
    );
  }
}

class MochiHomePage extends StatefulWidget {
  const MochiHomePage({super.key});

  @override
  State<MochiHomePage> createState() => _MochiHomePageState();
}

class _MochiHomePageState extends State<MochiHomePage> {
  // --- State for the Calendar ---
  // The calendar needs a variable to keep track of the currently selected day.
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- Top App Bar ---
      // This is the bar at the top of the screen.
      appBar: AppBar(
        title: const Text('My Mochi Journal'),
        leading: const Icon(Icons.menu_book_rounded), // A cute book icon
      ),
      // --- Main Content Area ---
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- The Calendar Widget ---
            // This is where we use the 'table_calendar' package we added.
            TableCalendar(
              firstDay: DateTime.utc(
                2020,
                1,
                1,
              ), // The first day the user can select
              lastDay: DateTime.utc(
                2030,
                12,
                31,
              ), // The last day the user can select
              focusedDay: _focusedDay, // The month that is currently in view
              calendarFormat: CalendarFormat.month, // Show one month at a time
              // --- Styling the Calendar to look cute ---
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false, // Hides the "2 weeks" button
                titleTextStyle: GoogleFonts.patrickHand(fontSize: 20.0),
              ),
              calendarStyle: CalendarStyle(
                // Style for the selected day
                selectedDecoration: const BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                // Style for today's date
                todayDecoration: BoxDecoration(
                  color: accentColor.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),

              // --- Handling User Interaction ---
              selectedDayPredicate: (day) {
                // This is used to determine which day is currently selected.
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                // This function is called when the user taps on a day.
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; // update `_focusedDay` here as well
                });
              },
            ),
          ],
        ),
      ),

      // --- Bottom Menu Bar Placeholder ---
      // This is your placeholder menu bar at the bottom.
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
            icon: Icon(Icons.add_circle_outline_rounded),
            label: 'New Entry',
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
