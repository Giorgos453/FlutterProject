import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:solbuddy_madrid/main.dart';

void main() {
  testWidgets('SolBuddy Madrid renders bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const SolBuddyApp());

    expect(find.text('SolBuddy Madrid'), findsOneWidget);
    expect(find.byIcon(Icons.wb_sunny_outlined), findsOneWidget);
    expect(find.byIcon(Icons.map_outlined), findsOneWidget);
    expect(find.byIcon(Icons.water_drop_outlined), findsOneWidget);
    expect(find.byIcon(Icons.quiz_outlined), findsOneWidget);
    expect(find.byIcon(Icons.person_outlined), findsOneWidget);
  });
}
