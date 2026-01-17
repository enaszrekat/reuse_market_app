import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_app/pages/my_products_page.dart';

void main() {
  testWidgets('MyProductsPage shows title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MyProductsPage(),
      ),
    );

    expect(find.text('My Products'), findsOneWidget);
  });
}
