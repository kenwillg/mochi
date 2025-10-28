import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/mood.dart';
import '../providers/journal_provider.dart';
import '../theme/app_theme.dart';

class DailyDetailsCard extends ConsumerWidget {
  const DailyDetailsCard({required this.date, super.key});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateKey = DateTime(date.year, date.month, date.day);

    final journalData = ref.watch(journalProvider);
    final selectedMood = journalData[dateKey];
    final isSaving = ref.watch(isSavingProvider);
    final formattedDate = DateFormat.yMMMMd().format(date);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formattedDate,
            style: GoogleFonts.patrickHand(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final mood in Mood.values)
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
                  selectedColor: AppTheme.primaryColor.withOpacity(0.7),
                ),
            ],
          ),
          const Divider(height: 30),
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
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
                  Text('Add a photo', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () async {
                ref.read(isSavingProvider.notifier).state = true;
                await Future.delayed(const Duration(seconds: 2));
                ref.read(isSavingProvider.notifier).state = false;

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
                  : const Text('Save Entry', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
