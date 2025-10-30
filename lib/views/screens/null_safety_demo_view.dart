import 'package:flutter/material.dart';

import 'package:mochi/views/widgets/demo_section.dart';
import 'package:mochi/views/widgets/demo_widgets.dart';

class NullSafetyDemoView extends StatelessWidget {
  const NullSafetyDemoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Null Safety Best Practices')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: const [
          DemoSection(
            title: 'Use nullable types intentionally',
            description:
                'Here the optional note starts out as null. We use the ?? operator to show a '
                'fallback message and avoid crashes when data is missing.',
            child: NullSafetyPreview(),
          ),
          DemoSection(
            title: 'Validate user input',
            description:
                'Forms combine TextField widgets with validation logic. Controllers are disposed '
                'to prevent leaks and validators return null when the input is safe to use.',
            child: ValidatedContactForm(),
          ),
          DemoSection(
            title: 'Stack and Image widgets working together',
            description:
                'Stack lets us overlay widgets, perfect for badges or captions. This example uses '
                'a real network Image with a positioned status label.',
            child: ProfileBadge(),
          ),
        ],
      ),
    );
  }
}
