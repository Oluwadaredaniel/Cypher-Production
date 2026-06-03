import 'package:cypher_pc/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PC Splash Screen loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CypherPCApp());

    // Verify that splash branding exists.
    expect(find.text('CYPHER PC'), findsOneWidget);
  });
}
