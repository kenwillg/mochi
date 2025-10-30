import 'package:flutter/material.dart';

import 'package:mochi/views/widgets/demo_section.dart';
import 'package:mochi/views/widgets/demo_widgets.dart';

class StatelessStatefulDemoView extends StatelessWidget {
  const StatelessStatefulDemoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stateless vs Stateful')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: const [
          DemoSection(
            title: 'Stateless Widgets',
            description:
                'Stateless widgets are immutable. They receive data from the outside and render '
                'UI once. To update them you must rebuild from a parent with new input.',
            child: StatelessInfoPanel(),
          ),
          DemoSection(
            title: 'Stateful Widgets',
            description:
                'Stateful widgets own mutable state. setState() marks the widget dirty so Flutter '
                'rebuilds it with the new values.',
            child: StatefulCounterDisplay(),
          ),
        ],
      ),
    );
  }
}
