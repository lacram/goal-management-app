import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:goal_management_app/data/models/goal.dart';
import 'package:goal_management_app/data/providers/goal_provider.dart';
import 'package:goal_management_app/presentation/screens/home/home_screen.dart';

void main() {
  group('Goal Management App Tests', () {
    testWidgets('Home screen loads successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => GoalProvider(),
            child: const HomeScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Verify that home screen loads
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    test('Goal model creation test', () {
      final goal = Goal(
        id: 1,
        title: 'Test Goal',
        description: 'Test Description',
        type: GoalType.daily,
        status: GoalStatus.active,
      );

      expect(goal.id, equals(1));
      expect(goal.title, equals('Test Goal'));
      expect(goal.type, equals(GoalType.daily));
      expect(goal.status, equals(GoalStatus.active));
    });

    test('Goal provider initialization test', () {
      final provider = GoalProvider();
      
      expect(provider.goals, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.error, isNull);
    });
  });
}