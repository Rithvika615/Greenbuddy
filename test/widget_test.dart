
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:green_buddy/main.dart';

void main() {
  testWidgets('GreenBuddy app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const GreenBuddy());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('GreenBuddy 🌱'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Plants'), findsOneWidget);
    expect(find.text('Reminders'), findsOneWidget);
  });
}
