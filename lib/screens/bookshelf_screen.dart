import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/journal_providers.dart';
import '../utils/constants.dart';
import 'year_view_screen.dart';

// --- BOOKSHELF SCREEN (Shows all years/books) ---
class BookshelfScreen extends ConsumerWidget {
  const BookshelfScreen({super.key});

  static const routeName = '/bookshelf';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalData = ref.watch(journalProvider);

    // Extract unique years from journal entries
    final years = journalData.keys
        .map((date) => date.year)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Sort descending (newest first)

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookshelf'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: years.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_books_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No books yet',
                    style: GoogleFonts.patrickHand(
                      fontSize: 24,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start journaling to create your first book!',
                    style: GoogleFonts.patrickHand(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: years.length,
              itemBuilder: (context, index) {
                final year = years[index];
                final yearEntries = journalData.entries
                    .where((entry) => entry.key.year == year)
                    .length;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                    child: InkWell(
                    onTap: () {
                      // Navigate to year view (showing months/chapters) for this year
                      Navigator.of(context).pushNamed(
                        YearViewScreen.routeName,
                        arguments: YearViewScreenArguments(year: year),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.menu_book_rounded,
                              size: 32,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$year',
                                  style: GoogleFonts.patrickHand(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$yearEntries ${yearEntries == 1 ? 'entry' : 'entries'}',
                                  style: GoogleFonts.patrickHand(
                                    fontSize: 16,
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

