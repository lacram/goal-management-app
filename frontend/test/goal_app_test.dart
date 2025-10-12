import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:goal_management_app/main.dart';
import 'package:goal_management_app/models/goal.dart';
import 'package:goal_management_app/services/goal_service.dart';
import 'package:goal_management_app/screens/goal_list_screen.dart';
import 'package:goal_management_app/screens/goal_form_screen.dart';
import 'package:goal_management_app/widgets/goal_card.dart';

import 'goal_app_test.mocks.dart';

@GenerateMocks([GoalService])
void main() {
  group('목표 관리 앱 위젯 테스트', () {
    late MockGoalService mockGoalService;

    setUp(() {
      mockGoalService = MockGoalService();
    });

    testWidgets('앱 초기 화면 로딩 테스트', (WidgetTester tester) async {
      // 빈 목표 리스트 반환 설정
      when(mockGoalService.getAllGoals()).thenAnswer((_) async => <Goal>[]);

      await tester.pumpWidget(MaterialApp(
        home: GoalListScreen(goalService: mockGoalService),
      ));

      // 앱바 제목 확인
      expect(find.text('목표 관리'), findsOneWidget);
      
      // 빈 상태 메시지 확인
      expect(find.text('목표가 없습니다'), findsOneWidget);
      
      // 플로팅 액션 버튼 확인
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('목표 리스트 표시 테스트', (WidgetTester tester) async {
      // 테스트용 목표 데이터
      final testGoals = [
        Goal(
          id: 1,
          title: '운동하기',
          description: '매일 30분 운동',
          type: GoalType.daily,
          status: GoalStatus.active,
          priority: 1,
          createdAt: DateTime.now(),
        ),
        Goal(
          id: 2,
          title: '독서하기',
          description: '주 2회 독서',
          type: GoalType.weekly,
          status: GoalStatus.completed,
          priority: 2,
          createdAt: DateTime.now(),
        ),
      ];

      when(mockGoalService.getAllGoals()).thenAnswer((_) async => testGoals);

      await tester.pumpWidget(MaterialApp(
        home: GoalListScreen(goalService: mockGoalService),
      ));

      // 데이터 로딩 대기
      await tester.pumpAndSettle();

      // 목표 카드 확인
      expect(find.byType(GoalCard), findsNWidgets(2));
      expect(find.text('운동하기'), findsOneWidget);
      expect(find.text('독서하기'), findsOneWidget);
    });

    testWidgets('목표 생성 폼 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GoalFormScreen(goalService: mockGoalService),
      ));

      // 폼 필드 확인
      expect(find.byType(TextFormField), findsNWidgets(2)); // 제목, 설명
      expect(find.byType(DropdownButtonFormField), findsOneWidget); // 타입
      expect(find.text('목표 저장'), findsOneWidget);

      // 제목 입력 테스트
      await tester.enterText(find.byType(TextFormField).first, '새로운 목표');
      expect(find.text('새로운 목표'), findsOneWidget);
    });

    testWidgets('목표 완료 토글 테스트', (WidgetTester tester) async {
      final testGoal = Goal(
        id: 1,
        title: '테스트 목표',
        description: '테스트용 목표',
        type: GoalType.daily,
        status: GoalStatus.active,
        priority: 1,
        createdAt: DateTime.now(),
      );

      when(mockGoalService.getAllGoals()).thenAnswer((_) async => [testGoal]);
      when(mockGoalService.completeGoal(1)).thenAnswer((_) async => testGoal.copyWith(
        status: GoalStatus.completed,
        completedAt: DateTime.now(),
      ));

      await tester.pumpWidget(MaterialApp(
        home: GoalListScreen(goalService: mockGoalService),
      ));

      await tester.pumpAndSettle();

      // 완료 체크박스 탭
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // 완료 API 호출 확인
      verify(mockGoalService.completeGoal(1)).called(1);
    });

    group('Goal 모델 테스트', () {
      test('Goal 객체 생성 테스트', () {
        final goal = Goal(
          id: 1,
          title: '테스트 목표',
          description: '테스트 설명',
          type: GoalType.daily,
          status: GoalStatus.active,
          priority: 1,
          createdAt: DateTime.now(),
        );

        expect(goal.id, equals(1));
        expect(goal.title, equals('테스트 목표'));
        expect(goal.type, equals(GoalType.daily));
        expect(goal.status, equals(GoalStatus.active));
      });

      test('Goal JSON 직렬화 테스트', () {
        final goal = Goal(
          id: 1,
          title: '테스트 목표',
          description: '테스트 설명',
          type: GoalType.daily,
          status: GoalStatus.active,
          priority: 1,
          createdAt: DateTime.now(),
        );

        final json = goal.toJson();
        expect(json['id'], equals(1));
        expect(json['title'], equals('테스트 목표'));
        expect(json['type'], equals('DAILY'));
        expect(json['status'], equals('ACTIVE'));
      });

      test('Goal JSON 역직렬화 테스트', () {
        final json = {
          'id': 1,
          'title': '테스트 목표',
          'description': '테스트 설명',
          'type': 'DAILY',
          'status': 'ACTIVE',
          'priority': 1,
          'createdAt': DateTime.now().toIso8601String(),
        };

        final goal = Goal.fromJson(json);
        expect(goal.id, equals(1));
        expect(goal.title, equals('테스트 목표'));
        expect(goal.type, equals(GoalType.daily));
        expect(goal.status, equals(GoalStatus.active));
      });

      test('Goal copyWith 테스트', () {
        final originalGoal = Goal(
          id: 1,
          title: '원본 목표',
          type: GoalType.daily,
          status: GoalStatus.active,
          priority: 1,
          createdAt: DateTime.now(),
        );

        final updatedGoal = originalGoal.copyWith(
          title: '수정된 목표',
          status: GoalStatus.completed,
        );

        expect(updatedGoal.id, equals(originalGoal.id));
        expect(updatedGoal.title, equals('수정된 목표'));
        expect(updatedGoal.status, equals(GoalStatus.completed));
        expect(updatedGoal.type, equals(originalGoal.type));
      });
    });

    group('GoalService 테스트', () {
      test('getAllGoals API 호출 테스트', () async {
        final testGoals = [
          Goal(
            id: 1,
            title: '테스트 목표',
            type: GoalType.daily,
            status: GoalStatus.active,
            priority: 1,
            createdAt: DateTime.now(),
          ),
        ];

        when(mockGoalService.getAllGoals()).thenAnswer((_) async => testGoals);

        final result = await mockGoalService.getAllGoals();
        
        expect(result, equals(testGoals));
        verify(mockGoalService.getAllGoals()).called(1);
      });

      test('createGoal API 호출 테스트', () async {
        final newGoal = Goal(
          title: '새 목표',
          description: '새 목표 설명',
          type: GoalType.daily,
          status: GoalStatus.active,
          priority: 1,
          createdAt: DateTime.now(),
        );

        final createdGoal = newGoal.copyWith(id: 1);

        when(mockGoalService.createGoal(newGoal))
            .thenAnswer((_) async => createdGoal);

        final result = await mockGoalService.createGoal(newGoal);
        
        expect(result.id, equals(1));
        expect(result.title, equals('새 목표'));
        verify(mockGoalService.createGoal(newGoal)).called(1);
      });

      test('updateGoal API 호출 테스트', () async {
        final updatedGoal = Goal(
          id: 1,
          title: '수정된 목표',
          type: GoalType.daily,
          status: GoalStatus.active,
          priority: 1,
          createdAt: DateTime.now(),
        );

        when(mockGoalService.updateGoal(1, updatedGoal))
            .thenAnswer((_) async => updatedGoal);

        final result = await mockGoalService.updateGoal(1, updatedGoal);
        
        expect(result.title, equals('수정된 목표'));
        verify(mockGoalService.updateGoal(1, updatedGoal)).called(1);
      });

      test('deleteGoal API 호출 테스트', () async {
        when(mockGoalService.deleteGoal(1)).thenAnswer((_) async {});

        await mockGoalService.deleteGoal(1);
        
        verify(mockGoalService.deleteGoal(1)).called(1);
      });

      test('completeGoal API 호출 테스트', () async {
        final completedGoal = Goal(
          id: 1,
          title: '완료된 목표',
          type: GoalType.daily,
          status: GoalStatus.completed,
          priority: 1,
          createdAt: DateTime.now(),
          completedAt: DateTime.now(),
        );

        when(mockGoalService.completeGoal(1))
            .thenAnswer((_) async => completedGoal);

        final result = await mockGoalService.completeGoal(1);
        
        expect(result.status, equals(GoalStatus.completed));
        expect(result.completedAt, isNotNull);
        verify(mockGoalService.completeGoal(1)).called(1);
      });
    });
  });
}
