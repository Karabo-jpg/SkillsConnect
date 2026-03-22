import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillconnect/presentation/pages/home_page.dart';

void main() {
  testWidgets('HomePage has a title and categories', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    // Verify SkillConnect title is present
    expect(find.text('SkillConnect'), findsOneWidget);

    // Verify Categories title is present
    expect(find.text('Categories'), findsOneWidget);

    // Verify at least one category label
    expect(find.text('Tailoring'), findsOneWidget);
  });
}
