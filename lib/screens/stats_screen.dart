import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/journal_entry.dart';
import '../models/mood.dart';
import '../providers/journal_providers.dart';
import '../utils/constants.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  static const routeName = '/stats';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalData = ref.watch(journalProvider);
    final stats = _calculateStats(journalData);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatCard(
            context: context,
            title: 'Total Entries',
            value: stats.totalEntries.toString(),
            icon: Icons.book,
            color: primaryColor,
            onTap: () => _showEntriesDetail(context, stats),
          ),
          _buildStatCard(
            context: context,
            title: 'Happy Days',
            value: stats.happyCount.toString(),
            icon: Icons.sentiment_very_satisfied,
            color: Colors.green,
            onTap: () => _showMoodDetail(context, 'Happy', stats.happyCount, Mood.happy, stats),
          ),
          _buildStatCard(
            context: context,
            title: 'Neutral Days',
            value: stats.neutralCount.toString(),
            icon: Icons.sentiment_neutral,
            color: Colors.orange,
            onTap: () => _showMoodDetail(context, 'Neutral', stats.neutralCount, Mood.neutral, stats),
          ),
          _buildStatCard(
            context: context,
            title: 'Sad Days',
            value: stats.sadCount.toString(),
            icon: Icons.sentiment_very_dissatisfied,
            color: Colors.blue,
            onTap: () => _showMoodDetail(context, 'Sad', stats.sadCount, Mood.sad, stats),
          ),
          _buildStatCard(
            context: context,
            title: 'Days with Drawings',
            value: stats.drawingCount.toString(),
            icon: Icons.draw,
            color: Colors.purple,
            onTap: () => _showDrawingDetail(context, stats),
          ),
          _buildStatCard(
            context: context,
            title: 'Days with Text',
            value: stats.textCount.toString(),
            icon: Icons.text_fields,
            color: Colors.teal,
            onTap: () => _showTextDetail(context, stats),
          ),
          _buildStatCard(
            context: context,
            title: 'Days with Stickers',
            value: stats.stickerCount.toString(),
            icon: Icons.emoji_emotions,
            color: Colors.pink,
            onTap: () => _showStickerDetail(context, stats),
          ),
          const SizedBox(height: 16),
          _buildMoodChart(context, stats),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: GoogleFonts.patrickHand(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodChart(BuildContext context, JournalStats stats) {
    final total = stats.totalEntries;
    if (total == 0) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No data available yet. Start journaling to see your mood trends!'),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood Distribution',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildMoodBar('Happy', stats.happyCount, total, Colors.green),
            const SizedBox(height: 12),
            _buildMoodBar('Neutral', stats.neutralCount, total, Colors.orange),
            const SizedBox(height: 12),
            _buildMoodBar('Sad', stats.sadCount, total, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodBar(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
            Text('${count} (${(percentage * 100).toStringAsFixed(1)}%)'),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  void _showEntriesDetail(BuildContext context, JournalStats stats) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Total Entries Detail'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You have ${stats.totalEntries} journal entries total.'),
            const SizedBox(height: 16),
            Text('Breakdown:'),
            const SizedBox(height: 8),
            Text('• ${stats.happyCount} happy days'),
            Text('• ${stats.neutralCount} neutral days'),
            Text('• ${stats.sadCount} sad days'),
            const SizedBox(height: 8),
            Text('• ${stats.drawingCount} entries with drawings'),
            Text('• ${stats.textCount} entries with text'),
            Text('• ${stats.stickerCount} entries with stickers'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showMoodDetail(
    BuildContext context,
    String moodName,
    int count,
    Mood mood,
    JournalStats stats,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$moodName Days Detail'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You had $count $moodName days.'),
            if (stats.totalEntries > 0) ...[
              const SizedBox(height: 8),
              Text(
                'That\'s ${((count / stats.totalEntries) * 100).toStringAsFixed(1)}% of all your entries.',
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDrawingDetail(BuildContext context, JournalStats stats) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Drawings Detail'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You have ${stats.drawingCount} entries with drawings.'),
            const SizedBox(height: 8),
            Text('Keep expressing yourself through art!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTextDetail(BuildContext context, JournalStats stats) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Text Entries Detail'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You have ${stats.textCount} entries with text notes.'),
            const SizedBox(height: 8),
            Text('Writing helps you reflect on your day!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showStickerDetail(BuildContext context, JournalStats stats) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stickers Detail'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You have ${stats.stickerCount} entries with stickers.'),
            const SizedBox(height: 8),
            Text('Stickers add fun to your journal!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  JournalStats _calculateStats(Map<DateTime, JournalEntry> journalData) {
    int totalEntries = 0;
    int happyCount = 0;
    int neutralCount = 0;
    int sadCount = 0;
    int drawingCount = 0;
    int textCount = 0;
    int stickerCount = 0;

    for (final entry in journalData.values) {
      if (entry.mood != null || entry.strokes.isNotEmpty || entry.stickers.isNotEmpty || entry.texts.isNotEmpty) {
        totalEntries++;
      }

      if (entry.mood == Mood.happy) happyCount++;
      if (entry.mood == Mood.neutral) neutralCount++;
      if (entry.mood == Mood.sad) sadCount++;
      if (entry.strokes.isNotEmpty) drawingCount++;
      if (entry.texts.isNotEmpty) textCount++;
      if (entry.stickers.isNotEmpty) stickerCount++;
    }

    return JournalStats(
      totalEntries: totalEntries,
      happyCount: happyCount,
      neutralCount: neutralCount,
      sadCount: sadCount,
      drawingCount: drawingCount,
      textCount: textCount,
      stickerCount: stickerCount,
    );
  }
}

class JournalStats {
  final int totalEntries;
  final int happyCount;
  final int neutralCount;
  final int sadCount;
  final int drawingCount;
  final int textCount;
  final int stickerCount;

  JournalStats({
    required this.totalEntries,
    required this.happyCount,
    required this.neutralCount,
    required this.sadCount,
    required this.drawingCount,
    required this.textCount,
    required this.stickerCount,
  });
}

