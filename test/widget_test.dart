import 'package:charlie_app/main.dart';
import 'package:charlie_app/providers/theme_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App launches with splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(CharlieApp(themeProvider: ThemeProvider()));
    expect(find.text('Charlie HRMS'), findsOneWidget);
  });
}
