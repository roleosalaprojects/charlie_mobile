import 'package:flutter_test/flutter_test.dart';
import 'package:charlie_app/main.dart';

void main() {
  testWidgets('App launches with splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CharlieApp());
    expect(find.text('Charlie HRMS'), findsOneWidget);
  });
}
