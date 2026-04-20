// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:money_mansion_skeleton/main.dart';

void main() {
  testWidgets('Money Mansion app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const MoneyMansionApp(isFirstLaunch: false, hasPrivacyConsent: true),
    );

    // Verify that the app displays game resources
    expect(find.text('111'), findsOneWidget); // Coins
    expect(find.text('780'), findsOneWidget); // Emeralds
    expect(find.text('7.7'), findsOneWidget); // Date

    // Verify that the calendar header is present
    expect(find.text('JUL'), findsOneWidget);
  });

  testWidgets('Navigation between screens works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const MoneyMansionApp(isFirstLaunch: false, hasPrivacyConsent: true),
    );

    // Initially on home screen (room viewer)
    await tester.pumpAndSettle();

    // Tap on the shop icon (index 2 - basket icon)
    final shopButton = find.byKey(const Key('nav_button_2'));
    await tester.tap(shopButton);
    await tester.pumpAndSettle();

    // Verify shop screen is displayed
    expect(find.text('Shop'), findsOneWidget);

    // Tap on stats icon (index 3)
    final statsButton = find.byKey(const Key('nav_button_3'));
    await tester.tap(statsButton);
    await tester.pumpAndSettle();

    // Verify stats screen is displayed
    expect(find.text('Statistics'), findsOneWidget);

    // Tap on inventory icon (index 4)
    final inventoryButton = find.byKey(const Key('nav_button_4'));
    await tester.tap(inventoryButton);
    await tester.pumpAndSettle();

    // Verify inventory screen is displayed
    expect(find.text('Inventory'), findsOneWidget);
  });
}
