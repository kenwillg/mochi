// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// UPDATED: Import app.dart instead of main.dart
import 'package:mochi/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // UPDATED: Wrap MochiApp in a ProviderScope for Riverpod
    await tester.pumpWidget(const ProviderScope(child: MochiApp()));

    // Verify that the calendar is showing.
    // We'll look for the "My Mochi Journal" title instead of the counter.
    expect(find.text('My Mochi Journal'), findsOneWidget);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our dialog has appeared.
    // We can look for the "Save Entry" button.
    expect(find.text('Save Entry'), findsOneWidget);
  });
}
