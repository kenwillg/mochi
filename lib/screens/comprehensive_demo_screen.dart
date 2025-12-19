import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../providers/journal_providers.dart';
import '../utils/constants.dart';

/// Comprehensive demo covering all Tugas 4 requirements
class ComprehensiveDemoScreen extends ConsumerStatefulWidget {
  const ComprehensiveDemoScreen({super.key});

  static const routeName = '/comprehensive-demo';

  @override
  ConsumerState<ComprehensiveDemoScreen> createState() => _ComprehensiveDemoScreenState();
}

class _ComprehensiveDemoScreenState extends ConsumerState<ComprehensiveDemoScreen> {
  // Variables and data types
  String _name = 'Flutter Learner';
  int _age = 20;
  double _height = 170.5;
  bool _isActive = true;
  List<String> _items = ['Item 1', 'Item 2', 'Item 3'];
  Map<String, dynamic> _userData = {'name': 'John', 'email': 'john@example.com'};

  // Control flow
  String _getGreeting() {
    if (_isActive) {
      return 'Welcome, $_name!';
    } else {
      return 'Account inactive';
    }
  }

  // Function example
  void _updateName(String newName) {
    setState(() {
      _name = newName;
    });
  }

  // OOP - Class example
  final _person = Person(name: 'Alice', age: 25);

  // Null safety
  String? _optionalMessage;
  bool _isLoading = false;
  String? _apiData;

  @override
  Widget build(BuildContext context) {
    // Using Riverpod provider
    final journalData = ref.watch(journalProvider);
    final entryCount = journalData.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Comprehensive Flutter Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Variables and Data Types
          _buildSection(
            title: '1. Variables & Data Types',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name (String): $_name'),
                Text('Age (int): $_age'),
                Text('Height (double): $_height'),
                Text('Active (bool): $_isActive'),
                Text('Items (List): ${_items.join(", ")}'),
                Text('User Data (Map): ${_userData.toString()}'),
              ],
            ),
          ),

          // Control Flow
          _buildSection(
            title: '2. Control Flow',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getGreeting()),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => setState(() => _isActive = !_isActive),
                  child: Text(_isActive ? 'Deactivate' : 'Activate'),
                ),
              ],
            ),
          ),

          // Function
          _buildSection(
            title: '3. Function',
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Enter name',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: _updateName,
                ),
                const SizedBox(height: 8),
                Text('Current name: $_name'),
              ],
            ),
          ),

          // OOP
          _buildSection(
            title: '4. Class & OOP',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Person: ${_person.name}, Age: ${_person.age}'),
                Text('Description: ${_person.getDescription()}'),
              ],
            ),
          ),

          // Null Safety
          _buildSection(
            title: '5. Null Safety',
            child: Column(
              children: [
                Text(_optionalMessage ?? 'No message set (null)'),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _optionalMessage = _optionalMessage == null
                          ? 'Message set!'
                          : null;
                    });
                  },
                  child: const Text('Toggle Message'),
                ),
              ],
            ),
          ),

          // Stateless vs Stateful
          _buildSection(
            title: '6. Stateless vs Stateful Widget',
            child: Column(
              children: [
                const StatelessCounter(),
                StatefulCounter(),
              ],
            ),
          ),

          // Basic Widgets
          _buildSection(
            title: '7. Text, Container, Row, Column, Image',
            child: Column(
              children: [
                const Text('Text Widget', style: TextStyle(fontSize: 18)),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: primaryColor.withOpacity(0.1),
                  child: const Text('Container Widget'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    Icon(Icons.star),
                    Icon(Icons.favorite),
                    Icon(Icons.thumb_up),
                  ],
                ),
                Image.network(
                  'https://picsum.photos/200/100',
                  height: 100,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('Image failed to load');
                  },
                ),
              ],
            ),
          ),

          // Padding, Margin, Alignment
          _buildSection(
            title: '8. Padding, Margin, Alignment',
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  color: accentColor.withOpacity(0.2),
                  child: const Text('Margin + Padding + Alignment'),
                ),
              ],
            ),
          ),

          // ListView, GridView, Stack
          _buildSection(
            title: '9. ListView, GridView, Stack',
            child: Column(
              children: [
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: List.generate(5, (i) => Container(
                      width: 80,
                      margin: const EdgeInsets.all(4),
                      color: Colors.blue.shade100,
                      child: Center(child: Text('Item $i')),
                    )),
                  ),
                ),
                const SizedBox(height: 8),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  children: List.generate(6, (i) => Container(
                    margin: const EdgeInsets.all(4),
                    color: Colors.green.shade100,
                    child: Center(child: Text('Grid $i')),
                  )),
                ),
                Stack(
                  children: [
                    Container(
                      height: 60,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                    ),
                    const Positioned(
                      top: 10,
                      left: 10,
                      child: Text('Stack Widget'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // TextField, Button, GestureDetector
          _buildSection(
            title: '10. TextField, Button, GestureDetector',
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Enter text',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Elevated'),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Outlined'),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Text'),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tapped!')),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.orange.shade100,
                    child: const Text('Tap me!'),
                  ),
                ),
              ],
            ),
          ),

          // Form & Validation
          _buildSection(
            title: '11. Form & Validation',
            child: _FormExample(),
          ),

          // setState
          _buildSection(
            title: '12. setState',
            child: StatefulCounter(),
          ),

          // Lifting State Up
          _buildSection(
            title: '13. Lifting State Up',
            child: _LiftingStateExample(),
          ),

          // Riverpod
          _buildSection(
            title: '14. Riverpod State Management',
            child: Column(
              children: [
                Text('Journal Entries: $entryCount'),
                ElevatedButton(
                  onPressed: () {
                    ref.read(journalProvider.notifier).reloadFromDatabase();
                  },
                  child: const Text('Reload from Database'),
                ),
              ],
            ),
          ),

          // Navigator
          _buildSection(
            title: '15. Navigator.push / pop',
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const _DetailsScreen(),
                  ),
                );
                if (result != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Returned: $result')),
                  );
                }
              },
              child: const Text('Push to Details Screen'),
            ),
          ),

          // Named Routes
          _buildSection(
            title: '16. Named Routes',
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/navigation-demo');
              },
              child: const Text('Go to Navigation Demo'),
            ),
          ),

          // HTTP Request
          _buildSection(
            title: '17. HTTP Request & JSON Parsing',
            child: Column(
              children: [
                if (_isLoading)
                  const CircularProgressIndicator()
                else if (_apiData != null)
                  Text(_apiData!)
                else
                  const Text('No data loaded'),
                ElevatedButton(
                  onPressed: _fetchData,
                  child: const Text('Fetch Data from API'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _apiData = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          _apiData = 'Title: ${data['title']}\nBody: ${data['body']}';
        });
      } else {
        setState(() {
          _apiData = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _apiData = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

// OOP Class Example
class Person {
  Person({required this.name, required this.age});

  final String name;
  final int age;

  String getDescription() {
    return '$name is $age years old';
  }
}

// Stateless Widget Example
class StatelessCounter extends StatelessWidget {
  const StatelessCounter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('This is a Stateless Widget (immutable)');
  }
}

// Stateful Widget Example
class StatefulCounter extends StatefulWidget {
  StatefulCounter({super.key});

  @override
  State<StatefulCounter> createState() => _StatefulCounterState();
}

class _StatefulCounterState extends State<StatefulCounter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => setState(() => _count--),
          child: const Text('-'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Count: $_count'),
        ),
        ElevatedButton(
          onPressed: () => setState(() => _count++),
          child: const Text('+'),
        ),
      ],
    );
  }
}

// Form Example
class _FormExample extends StatefulWidget {
  @override
  State<_FormExample> createState() => _FormExampleState();
}

class _FormExampleState extends State<_FormExample> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Form is valid!')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

// Lifting State Up Example
class _LiftingStateExample extends StatefulWidget {
  @override
  State<_LiftingStateExample> createState() => _LiftingStateExampleState();
}

class _LiftingStateExampleState extends State<_LiftingStateExample> {
  String _selectedValue = 'Option 1';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Selected: $_selectedValue'),
        const SizedBox(height: 8),
        _ChildWidget(
          selectedValue: _selectedValue,
          onChanged: (value) {
            setState(() {
              _selectedValue = value;
            });
          },
        ),
      ],
    );
  }
}

class _ChildWidget extends StatelessWidget {
  const _ChildWidget({
    required this.selectedValue,
    required this.onChanged,
  });

  final String selectedValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ['Option 1', 'Option 2', 'Option 3'].map((option) {
        return ChoiceChip(
          label: Text(option),
          selected: selectedValue == option,
          onSelected: (_) => onChanged(option),
        );
      }).toList(),
    );
  }
}

class _DetailsScreen extends StatelessWidget {
  const _DetailsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context, 'Data from details screen');
          },
          child: const Text('Pop with Data'),
        ),
      ),
    );
  }
}

