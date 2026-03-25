import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillconnect/presentation/pages/success_page.dart';

void main() {
  testWidgets('SuccessPage displays correct booking details', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: SuccessPage(
        serviceName: 'Tailoring',
        amount: 50000,
        providerName: 'Faith',
      ),
    ));

    // Verify Success title
    expect(find.text('Confirmed!'), findsOneWidget);

    // Verify concatenated service string
    expect(
      find.text('Your booking for "Tailoring" with Faith has been confirmed.\n\nDeposit: 50000 UGX secured via Mobile Money.'),
      findsOneWidget,
    );
    
    // Verify the Done button
    expect(find.text('Done'), findsOneWidget);
  });
}
