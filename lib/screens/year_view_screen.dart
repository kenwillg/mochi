import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/journal_providers.dart';
import '../utils/constants.dart';
import 'home_screen.dart';

// --- YEAR VIEW SCREEN (Shows all months/chapters for a year) ---
class YearViewScreen extends ConsumerWidget {
  const YearViewScreen({super.key});

  static const routeName = '/year';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is! YearViewScreenArguments) {
      return const Scaffold(
        body: Center(child: Text('Invalid arguments')),
      );
    }

    final year = args.year;
    final journalData = ref.watch(journalProvider);

    // Extract unique months for this year
    final months = journalData.keys
        .where((date) => date.year == year)
        .map((date) => date.month)
        .toSet()
        .toList()
      ..sort();

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
        title: Text('$year'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: months.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No chapters yet',
                    style: GoogleFonts.patrickHand(
                      fontSize: 24,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: months.length,
              itemBuilder: (context, index) {
                final month = months[index];
                final monthEntries = journalData.entries
                    .where((entry) =>
                        entry.key.year == year && entry.key.month == month)
                    .length;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      // Navigate to home screen (calendar) with the selected month/year focused
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const MochiHomePage(),
                          settings: RouteSettings(
                            name: '/',
                            arguments: {'year': year, 'month': month},
                          ),
                        ),
                        (route) => false,
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${month.toString().padLeft(2, '0')}',
                                style: GoogleFonts.patrickHand(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  monthNames[month - 1],
                                  style: GoogleFonts.patrickHand(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Chapter ${index + 1} • $monthEntries ${monthEntries == 1 ? 'entry' : 'entries'}',
                                  style: GoogleFonts.patrickHand(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class YearViewScreenArguments {
  final int year;

  YearViewScreenArguments({required this.year});
}

