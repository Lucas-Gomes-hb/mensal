import 'package:flutter_test/flutter_test.dart';
import 'package:mensal/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MensalApp());
    expect(find.text('Mensal'), findsWidgets);
  });
}
