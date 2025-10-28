import 'package:flutter/material.dart';

import 'lifting_state_demo_screen.dart';
import 'null_safety_demo_screen.dart';
import 'set_state_demo_screen.dart';
import 'stateless_stateful_demo_screen.dart';

class DemoMenuScreen extends StatelessWidget {
  const DemoMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final demos = [
      _DemoEntry(
        title: 'Stateless vs Stateful widgets',
        subtitle: 'Compare immutable and mutable widget lifecycles.',
        builder: (_) => const StatelessStatefulDemoScreen(),
      ),
      _DemoEntry(
        title: 'Understanding setState',
        subtitle: 'See how setState triggers rebuilds and responds to gestures.',
        builder: (_) => const SetStateDemoScreen(),
      ),
      _DemoEntry(
        title: 'Lifting State Up',
        subtitle: 'Share data between widgets by letting the parent own it.',
        builder: (_) => const LiftingStateDemoScreen(),
      ),
      _DemoEntry(
        title: 'Null Safety Best Practices',
        subtitle: 'Handle nullable data, validate forms, and overlay widgets safely.',
        builder: (_) => const NullSafetyDemoScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Learning Demos')),
      body: ListView.separated(
        itemCount: demos.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, index) {
          final demo = demos[index];
          return ListTile(
            title: Text(demo.title),
            subtitle: Text(demo.subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: demo.builder),
            ),
          );
        },
      ),
    );
  }
}

class _DemoEntry {
  const _DemoEntry({
    required this.title,
    required this.subtitle,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final WidgetBuilder builder;
}
