import 'package:flutter_test/flutter_test.dart';
import 'package:cat_tinder/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CatTinderApp());

    // Verify that the app starts
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
