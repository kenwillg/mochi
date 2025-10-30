import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/journal_entry.dart';
import '../models/mood.dart';
import '../providers/journal_providers.dart';
import '../utils/constants.dart';
import '../screens/journal_entry_screen.dart';

// --- THE REUSABLE DETAILS CARD (Used in the Dialog) ---
class DailyDetailsCard extends ConsumerWidget {
  final DateTime date; // The card now knows which date it is working on.

  const DailyDetailsCard({required this.date, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // To properly check our map, we must ignore the time part of the date.
    final dateKey = DateTime(date.year, date.month, date.day);

    final journalData = ref.watch(journalProvider);
    final selectedEntry =
        journalData[dateKey] ?? const JournalEntry(); // Look up using the dateKey
    final selectedMood = selectedEntry.mood;
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
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              Navigator.of(context).pushNamed(
                JournalEntryScreen.routeName,
                arguments: JournalEntryScreenArguments(date: dateKey),
              );
            },
            child: Container(
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.draw_rounded, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedEntry.strokes.isEmpty &&
                              selectedEntry.stickers.isEmpty
                          ? 'Make a journal entry'
                          : 'Edit journal entry',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
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
