// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bingo_app/main.dart';

import 'package:bingo_app/flavors/app_config.dart';

void main() {
  testWidgets('Splash screen shows up', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      BingoApp(
        appConfig: AppConfig(
          flavor: Flavor.dev,
          appTitle: 'Test App',
          apiBaseUrl: '',
        ),
      ),
    );

    // Verify that the splash screen is shown.
    expect(find.text('Inicializando o Bingo...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
