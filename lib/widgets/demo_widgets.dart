import 'package:flutter/material.dart';

/// Simple stateless info panel used to describe immutable UI.
class StatelessInfoPanel extends StatelessWidget {
  const StatelessInfoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'This panel is a StatelessWidget. It renders once with the data it receives '
      'and never calls setState. Try leaving and returning to this screen – the '
      'message stays the same because nothing is stored internally.',
    );
  }
}

/// A stateful counter that highlights how internal mutable state works.
class StatefulCounterDisplay extends StatefulWidget {
  const StatefulCounterDisplay({super.key});

  @override
  State<StatefulCounterDisplay> createState() => _StatefulCounterDisplayState();
}

class _StatefulCounterDisplayState extends State<StatefulCounterDisplay> {
  int _count = 0;

  void _increment() {
    setState(() => _count++);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Button taps: $_count', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _increment,
          icon: const Icon(Icons.add),
          label: const Text('Tap to call setState'),
        ),
      ],
    );
  }
}

/// A colorful square that toggles its shade with every tap.
class GestureColorBox extends StatefulWidget {
  const GestureColorBox({super.key});

  @override
  State<GestureColorBox> createState() => _GestureColorBoxState();
}

class _GestureColorBoxState extends State<GestureColorBox> {
  static const _colors = [Colors.teal, Colors.deepOrange, Colors.indigo];
  int _index = 0;

  void _cycleColor() {
    setState(() => _index = (_index + 1) % _colors.length);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _cycleColor,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 120,
        decoration: BoxDecoration(
          color: _colors[_index],
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: Text(
            'Tap me',
            style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

/// Stateless tiles used by the lifted state example.
class MoodChoiceGrid extends StatelessWidget {
  const MoodChoiceGrid({
    super.key,
    required this.choices,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<MoodChoice> choices;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: choices.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final choice = choices[index];
        final isSelected = selectedIndex == index;
        return Material(
          color: isSelected ? choice.color.withOpacity(0.8) : choice.color.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onSelected(index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(choice.icon, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text(
                  choice.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MoodChoice {
  const MoodChoice({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

const moodChoices = <MoodChoice>[
  MoodChoice(label: 'Focused', icon: Icons.psychology, color: Colors.indigo),
  MoodChoice(label: 'Calm', icon: Icons.self_improvement, color: Colors.teal),
  MoodChoice(label: 'Creative', icon: Icons.brush, color: Colors.deepOrange),
  MoodChoice(label: 'Curious', icon: Icons.travel_explore, color: Colors.purple),
  MoodChoice(label: 'Joyful', icon: Icons.sentiment_satisfied, color: Colors.amber),
  MoodChoice(label: 'Rested', icon: Icons.bedtime, color: Colors.blueGrey),
];

/// A null-safe profile preview that demonstrates optional data handling.
class NullSafetyPreview extends StatefulWidget {
  const NullSafetyPreview({super.key});

  @override
  State<NullSafetyPreview> createState() => _NullSafetyPreviewState();
}

class _NullSafetyPreviewState extends State<NullSafetyPreview> {
  String? _note;

  void _toggleNote() {
    setState(() {
      _note = _note == null ? 'Null safety helps us avoid crashes when data is missing.' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final message = _note ?? 'Tap the button to safely provide a note.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(message),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _toggleNote,
          child: Text(_note == null ? 'Provide optional note' : 'Clear note (set to null)'),
        ),
      ],
    );
  }
}

/// A form with validation that practices disposing controllers safely.
class ValidatedContactForm extends StatefulWidget {
  const ValidatedContactForm({super.key});

  @override
  State<ValidatedContactForm> createState() => _ValidatedContactFormState();
}

class _ValidatedContactFormState extends State<ValidatedContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      setState(() => _submitted = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome, ${_nameController.text.trim()}!')),
      );
    }
  }

  String? _validateRequired(String? value, String fieldName) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: _submitted
          ? AutovalidateMode.always
          : AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (value) => _validateRequired(value, 'Name'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleSubmit,
              child: const Text('Validate and Submit'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Displays a remote profile photo with a badge overlay using Stack and Image widgets.
class ProfileBadge extends StatelessWidget {
  const ProfileBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(60),
          child: Image.network(
            'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&w=240&q=60',
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          bottom: -6,
          right: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.greenAccent.shade700,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  'Live',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
