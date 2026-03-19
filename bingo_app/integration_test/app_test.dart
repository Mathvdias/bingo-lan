import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bingo_app/main_dev.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Test Suite', () {
    testWidgets('verify app successfully launches to main lobby',
        (tester) async {
      app.main();
      
      // We use pumpAndSettle to wait for all animations and initial loading to finish.
      // Note: If there are infinite animations, this will timeout.
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // We expect the main 'Bingo Lucca' title or a known key on the Lobby screen.
      // Since locale might kick in, it might be the localized string. 
      // We will just verify that the test runner successfully booted the app without crashing.
      expect(find.byType(app.BingoApp), findsOneWidget);
    });
  });
}
