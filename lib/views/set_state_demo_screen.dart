import 'package:flutter/material.dart';

import '../widgets/demo_section.dart';
import '../widgets/demo_widgets.dart';

class SetStateDemoScreen extends StatefulWidget {
  const SetStateDemoScreen({super.key});

  @override
  State<SetStateDemoScreen> createState() => _SetStateDemoScreenState();
}

class _SetStateDemoScreenState extends State<SetStateDemoScreen> {
  double _fontScale = 18;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Working with setState')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          DemoSection(
            title: 'setState updates local fields',
            description:
                'Moving this slider calls setState and rebuilds only the widgets that depend on '
                'the font size value.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Drag to resize me!',
                  style: TextStyle(fontSize: _fontScale, fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: _fontScale,
                  min: 16,
                  max: 32,
                  onChanged: (value) => setState(() => _fontScale = value),
                ),
              ],
            ),
          ),
          const DemoSection(
            title: 'GestureDetector + setState',
            description:
                'GestureDetector lets us listen for taps, drags, and more. Here we use it to '
                'cycle background colors with setState.',
            child: GestureColorBox(),
          ),
        ],
      ),
    );
  }
}
