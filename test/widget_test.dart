import 'package:flutter_test/flutter_test.dart';

import 'package:product_catalog_flutter/main.dart';

void main() {
  testWidgets('Entry screen shows welcome copy and an Enter Catalog button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Enter Catalog'), findsOneWidget);
  });
}
