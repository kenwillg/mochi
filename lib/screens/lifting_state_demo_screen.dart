import 'package:flutter/material.dart';

import '../widgets/demo_section.dart';
import '../widgets/demo_widgets.dart';

class LiftingStateDemoScreen extends StatefulWidget {
  const LiftingStateDemoScreen({super.key});

  @override
  State<LiftingStateDemoScreen> createState() => _LiftingStateDemoScreenState();
}

class _LiftingStateDemoScreenState extends State<LiftingStateDemoScreen> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final selectedMood =
        _selectedIndex != null ? moodChoices[_selectedIndex!].label : 'None yet';
    return Scaffold(
      appBar: AppBar(title: const Text('Lifting State Up')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          DemoSection(
            title: 'Parent owns the state',
            description:
                'The grid below is a StatelessWidget. The selection lives here in the parent, '
                'so siblings (like this summary text) can react to changes as well.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Selected mood: $selectedMood'),
                const SizedBox(height: 12),
                MoodChoiceGrid(
                  choices: moodChoices,
                  selectedIndex: _selectedIndex,
                  onSelected: (index) => setState(() => _selectedIndex = index),
                ),
              ],
            ),
          ),
          DemoSection(
            title: 'Why lift state?',
            description:
                'When multiple widgets need access to the same value, store it in the closest '
                'common ancestor instead of duplicating mutable fields.',
            child: const Text(
              'Here, both the summary text and the grid rebuild when you select a new mood. '
              'The grid remains stateless and reusable because it simply notifies the parent '
              'through the onSelected callback.',
            ),
          ),
        ],
      ),
    );
  }
}
