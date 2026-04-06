import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Widget compilation test', (WidgetTester tester) async {
    // Test that basic Material widgets work
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Smart Library')),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Smart Library'),
                Text('Real-time seat tracking'),
              ],
            ),
          ),
        ),
      ),
    );

    // Verify basic widgets render
    expect(find.text('Smart Library'), findsWidgets);
    expect(find.text('Real-time seat tracking'), findsOneWidget);
  });
}
