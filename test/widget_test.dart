import 'package:flutter_test/flutter_test.dart';
import 'package:bkash_implement/main.dart';
import 'package:bkash_implement/services/bkash_service.dart';

void main() {
  testWidgets('bKash app smoke test', (WidgetTester tester) async {
    final bkashService = BkashService();
    await tester.pumpWidget(BkashApp(bkashService: bkashService));
    expect(find.text('bKash'), findsWidgets);
  });
}
