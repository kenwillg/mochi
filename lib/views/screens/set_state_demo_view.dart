import 'package:flutter/material.dart';

import 'package:mochi/views/widgets/demo_section.dart';
import 'package:mochi/views/widgets/demo_widgets.dart';

class SetStateDemoView extends StatefulWidget {
  const SetStateDemoView({super.key});

  @override
  State<SetStateDemoView> createState() => _SetStateDemoViewState();
}

class _SetStateDemoViewState extends State<SetStateDemoView> {
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
