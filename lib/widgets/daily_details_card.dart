import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/journal_entry.dart';
import '../models/mood.dart';
import '../models/weather_info.dart';
import '../providers/journal_providers.dart';
import '../providers/weather_provider.dart';
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
        journalData[dateKey] ??
        const JournalEntry(); // Look up using the dateKey
    final selectedMood = selectedEntry.mood;
    final savedWeather = selectedEntry.weather;
    final isSaving = ref.watch(isSavingProvider);
    final formattedDate = DateFormat.yMMMMd().format(date);
    final weatherAsync = ref.watch(weatherProvider);

    // If mood is already set, show view mode (mood + weather + journal button)
    // Otherwise, show edit mode (mood selection + save)
    final isViewMode = selectedMood != null;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formattedDate,
            style: GoogleFonts.patrickHand(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          
          if (isViewMode) ...[
            // VIEW MODE: Show saved mood
            Text(
              'Your mood',
              style: GoogleFonts.patrickHand(
                fontSize: 18,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            _MoodDisplay(mood: selectedMood),
            const SizedBox(height: 32),
            
            // Show saved weather if available
            if (savedWeather != null) ...[
              const Divider(),
              const SizedBox(height: 24),
              Text(
                'Weather',
                style: GoogleFonts.patrickHand(
                  fontSize: 18,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),
              _WeatherDisplay(weather: savedWeather),
              const SizedBox(height: 24),
            ],
            
            // Button to open journal entry
            const Divider(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    JournalEntryScreen.routeName,
                    arguments: JournalEntryScreenArguments(date: dateKey),
                  );
                },
                icon: const Icon(Icons.draw_rounded),
                label: Text(
                  selectedEntry.strokes.isEmpty && selectedEntry.stickers.isEmpty
                      ? 'Open journal entry'
                      : 'Edit journal entry',
                  style: GoogleFonts.patrickHand(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Close',
                  style: GoogleFonts.patrickHand(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ] else ...[
            // EDIT MODE: Mood selection
            Text(
              'How are you feeling? *',
              style: GoogleFonts.patrickHand(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final mood in Mood.values)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: _MoodButton(
                        mood: mood,
                        isSelected: selectedMood == mood,
                        onTap: () {
                          // Update mood - weather will be saved when user clicks Save
                          ref
                              .read(journalProvider.notifier)
                              .updateMood(dateKey, mood);
                        },
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 24),
            // Optional journal entry section (smaller, less prominent)
            Text(
              'Optional: Add journal entry',
              style: GoogleFonts.patrickHand(
                fontSize: 14,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                Navigator.of(context).pushNamed(
                  JournalEntryScreen.routeName,
                  arguments: JournalEntryScreenArguments(date: dateKey),
                );
              },
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    style: BorderStyle.solid,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.draw_rounded, color: Colors.grey, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedEntry.strokes.isEmpty &&
                                selectedEntry.stickers.isEmpty
                            ? 'Add drawing or stickers (optional)'
                            : 'Edit journal entry',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: Colors.grey, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedMood != null ? accentColor : Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: selectedMood != null ? () async {
                  final moodToSave = selectedMood; // Store in local variable (already checked for null)
                  ref.read(isSavingProvider.notifier).setSaving(true);
                  
                  // Get current weather if available and save it with the entry
                  final currentEntry = ref.read(journalProvider)[dateKey] ?? const JournalEntry();
                  WeatherInfo? weatherToSave = currentEntry.weather;
                  
                  // If weather is not already saved, try to get current weather
                  if (weatherToSave == null) {
                    // Get weather value if available
                    weatherAsync.when(
                      data: (weather) => weatherToSave = weather,
                      loading: () {},
                      error: (_, __) {},
                    );
                  }
                  
                  // Update entry with weather if we have it
                  if (weatherToSave != null && currentEntry.weather == null) {
                    ref.read(journalProvider.notifier).updateMood(
                      dateKey,
                      moodToSave,
                      weather: weatherToSave,
                    );
                  }
                  
                  await Future.delayed(const Duration(seconds: 2));
                  ref.read(isSavingProvider.notifier).setSaving(false);

                  if (context.mounted) {
                    Navigator.of(context).pop(true);
                  }
                } : null,
                child: isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Text(
                        selectedMood != null ? "Save" : "Select a mood to save",
                        style: GoogleFonts.patrickHand(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// --- Mood Display Widget (Read-only) ---
class _MoodDisplay extends StatelessWidget {
  final Mood mood;

  const _MoodDisplay({required this.mood});

  @override
  Widget build(BuildContext context) {
    final icon = mood == Mood.happy
        ? Icons.sentiment_very_satisfied
        : mood == Mood.neutral
            ? Icons.sentiment_neutral
            : Icons.sentiment_very_dissatisfied;

    final color = mood == Mood.happy
        ? Colors.green
        : mood == Mood.neutral
            ? Colors.orange
            : Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: color,
          ),
          const SizedBox(width: 16),
          Text(
            mood.name.toUpperCase(),
            style: GoogleFonts.patrickHand(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Weather Display Widget ---
class _WeatherDisplay extends StatelessWidget {
  final WeatherInfo weather;

  const _WeatherDisplay({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (weather.conditionIconUrl.isNotEmpty)
            Image.network(
              weather.conditionIconUrl,
              width: 48,
              height: 48,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.cloud_outlined, size: 48, color: Colors.blue.shade700),
            )
          else
            Icon(Icons.cloud_outlined, size: 48, color: Colors.blue.shade700),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weather.conditionText,
                  style: GoogleFonts.patrickHand(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${weather.temperatureC.toStringAsFixed(1)}°C',
                  style: GoogleFonts.patrickHand(
                    fontSize: 16,
                    color: Colors.blue.shade700,
                  ),
                ),
                if (weather.locationName.isNotEmpty)
                  Text(
                    weather.locationName,
                    style: GoogleFonts.patrickHand(
                      fontSize: 14,
                      color: Colors.blue.shade600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Big Mood Button Widget ---
class _MoodButton extends StatelessWidget {
  final Mood mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodButton({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = mood == Mood.happy
        ? Icons.sentiment_very_satisfied
        : mood == Mood.neutral
            ? Icons.sentiment_neutral
            : Icons.sentiment_very_dissatisfied;

    final color = mood == Mood.happy
        ? Colors.green
        : mood == Mood.neutral
            ? Colors.orange
            : Colors.blue;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.25)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 56,
              color: isSelected ? color : Colors.grey.shade600,
            ),
            const SizedBox(height: 10),
            Text(
              mood.name.toUpperCase(),
              style: GoogleFonts.patrickHand(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
