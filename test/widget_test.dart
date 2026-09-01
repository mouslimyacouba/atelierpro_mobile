import 'package:flutter_test/flutter_test.dart';
import 'package:atelierpro_mobile/main.dart';

void main() {
  testWidgets('AtelierProApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AtelierProApp());
    expect(find.byType(AtelierProApp), findsOneWidget);
  });
}
