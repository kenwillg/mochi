import 'package:flutter/material.dart';

/// Navigation demo showing:
/// * Direct [Navigator.push] usage with inline [MaterialPageRoute].
/// * Named route navigation, including argument passing via [RouteSettings.arguments].
/// * Returning data from child pages with [Navigator.pop] and surfacing the
///   results back in the parent UI.
class NavigationDemoView extends StatefulWidget {
  const NavigationDemoView({super.key});

  static const routeName = '/navigation-demo';

  /// Handles named routes that need strongly typed arguments.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == NamedRouteDetailsScreen.routeName) {
      final args = settings.arguments;
      if (args is NamedRouteDetailsArgs) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => NamedRouteDetailsScreen(args: args),
        );
      }

      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const _NavigationErrorScreen(
          message: 'NamedRouteDetailsScreen expects a NamedRouteDetailsArgs payload.',
        ),
      );
    }

    return null;
  }

  @override
  State<NavigationDemoView> createState() => _NavigationDemoViewState();
}

class _NavigationDemoViewState extends State<NavigationDemoView> {
  String? _directNavigationResult;
  String? _namedRouteResult;

  Future<void> _openDirectPushExample() async {
    final now = TimeOfDay.now();
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => DirectPushDetailsScreen(
          greeting: 'Direct push launched at ${now.format(context)}',
        ),
      ),
    );

    if (!mounted) return;
    setState(() => _directNavigationResult = result);
  }

  Future<void> _openNamedRouteExample() async {
    final args = NamedRouteDetailsArgs(
      prompt: 'What should we log from the named route flow?',
      suggestion: _directNavigationResult,
    );

    final result = await Navigator.of(context).pushNamed<String>(
      NamedRouteDetailsScreen.routeName,
      arguments: args,
    );

    if (!mounted) return;
    setState(() => _namedRouteResult = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigator push vs named routes')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This page wires up both navigation styles so you can inspect the '
              'argument payloads and the values returned on Navigator.pop.',
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _openDirectPushExample,
              icon: const Icon(Icons.door_front_door_outlined),
              label: const Text('Open details with Navigator.push'),
            ),
            if (_directNavigationResult != null) ...[
              const SizedBox(height: 8),
              _ResultBanner(
                title: 'Result from direct push',
                value: _directNavigationResult!,
              ),
            ],
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _openNamedRouteExample,
              icon: const Icon(Icons.route_outlined),
              label: const Text('Open details with Navigator.pushNamed'),
            ),
            if (_namedRouteResult != null) ...[
              const SizedBox(height: 8),
              _ResultBanner(
                title: 'Result from named route',
                value: _namedRouteResult!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DirectPushDetailsScreen extends StatefulWidget {
  const DirectPushDetailsScreen({
    super.key,
    required this.greeting,
  });

  final String greeting;

  @override
  State<DirectPushDetailsScreen> createState() => _DirectPushDetailsScreenState();
}

class _DirectPushDetailsScreenState extends State<DirectPushDetailsScreen> {
  late final TextEditingController _responseController;

  @override
  void initState() {
    super.initState();
    _responseController = TextEditingController();
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(
      _responseController.text.isEmpty
          ? 'Direct flow closed without additional notes.'
          : 'Direct flow says: ${_responseController.text}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Direct push details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.greeting),
            const SizedBox(height: 12),
            const Text(
              'This screen was pushed with a MaterialPageRoute so we could pass '
              'a strongly typed constructor argument. Enter a reply below to send '
              'data back when you close the page.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _responseController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Reply to send back',
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Return to previous screen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NamedRouteDetailsArgs {
  const NamedRouteDetailsArgs({
    required this.prompt,
    this.suggestion,
  });

  final String prompt;
  final String? suggestion;
}

class NamedRouteDetailsScreen extends StatefulWidget {
  const NamedRouteDetailsScreen({super.key, required this.args});

  static const routeName = '/navigation-demo/named-details';

  final NamedRouteDetailsArgs args;

  @override
  State<NamedRouteDetailsScreen> createState() => _NamedRouteDetailsScreenState();
}

class _NamedRouteDetailsScreenState extends State<NamedRouteDetailsScreen> {
  late final TextEditingController _entryController;

  @override
  void initState() {
    super.initState();
    _entryController = TextEditingController(text: widget.args.suggestion ?? '');
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  void _completeFlow() {
    Navigator.of(context).pop(
      _entryController.text.isEmpty
          ? 'Named route finished with no extra message.'
          : 'Named route captured: ${_entryController.text}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Named route details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.args.prompt),
            const SizedBox(height: 12),
            const Text(
              'This page was resolved through onGenerateRoute so we could decode '
              'arguments from RouteSettings and guarantee strong typing.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _entryController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Message to return',
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _completeFlow(),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _completeFlow,
                icon: const Icon(Icons.reply_outlined),
                label: const Text('Pop with result'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}

class _NavigationErrorScreen extends StatelessWidget {
  const _NavigationErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
