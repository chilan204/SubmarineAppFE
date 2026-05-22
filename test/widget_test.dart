import 'package:flutter_test/flutter_test.dart';
import 'package:submarine_flutter/main.dart';

void main() {
  testWidgets('App launches without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const NauticomApp());
    expect(find.byType(NauticomApp), findsOneWidget);
  });
}
