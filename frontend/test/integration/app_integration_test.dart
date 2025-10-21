import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:goal_management_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Goal Management App Integration Tests', () {
    testWidgets('App launches and shows home screen', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Verify app launches successfully
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}