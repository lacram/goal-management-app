import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:goal_management_app/main.dart' as app;
import 'package:goal_management_app/models/goal.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('목표 관리 앱 통합 테스트', () {
    testWidgets('전체 워크플로우 테스트: 목표 생성부터 완료까지', (WidgetTester tester) async {
      // 앱 시작
      app.main();
      await tester.pumpAndSettle();

      // 초기 화면 확인
      expect(find.text('목표 관리'), findsOneWidget);

      // 1. 목표 생성 - 플로팅 액션 버튼 탭
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // 목표 생성 폼 화면 확인
      expect(find.text('새 목표'), findsOneWidget);
      expect(find.byType(TextFormField), findsAtLeastNWidgets(2));

      // 목표 정보 입력
      await tester.enterText(
        find.widgetWithText(TextFormField, '목표 제목을 입력하세요'), 
        '매일 운동하기'
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '목표 설명을 입력하세요'), 
        '매일 30분 이상 운동하기'
      );

      // 목표 타입 선택 (일간)
      await tester.tap(find.byType(DropdownButtonFormField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('일간').last);
      await tester.pumpAndSettle();

      // 우선순위 설정
      await tester.tap(find.text('높음'));
      await tester.pumpAndSettle();

      // 저장 버튼 탭
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      // 목표 리스트 화면으로 돌아가기 확인
      expect(find.text('목표 관리'), findsOneWidget);
      expect(find.text('매일 운동하기'), findsOneWidget);

      // 2. 목표 완료 처리
      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();

      // 완료 상태 확인 (체크된 상태)
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox).first);
      expect(checkbox.value, isTrue);

      // 3. 목표 상세 보기
      await tester.tap(find.text('매일 운동하기'));
      await tester.pumpAndSettle();

      // 상세 화면 확인
      expect(find.text('목표 상세'), findsOneWidget);
      expect(find.text('매일 운동하기'), findsOneWidget);
      expect(find.text('매일 30분 이상 운동하기'), findsOneWidget);
      expect(find.text('완료됨'), findsOneWidget);

      // 뒤로 가기
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // 4. 목표 수정
      await tester.longPress(find.text('매일 운동하기'));
      await tester.pumpAndSettle();

      // 컨텍스트 메뉴에서 수정 선택
      await tester.tap(find.text('수정'));
      await tester.pumpAndSettle();

      // 제목 수정
      await tester.enterText(
        find.widgetWithText(TextFormField, '매일 운동하기'), 
        '매일 1시간 운동하기'
      );

      // 저장
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      // 수정된 제목 확인
      expect(find.text('매일 1시간 운동하기'), findsOneWidget);
    });

    testWidgets('계층적 목표 생성 및 관리 테스트', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 1. 부모 목표 생성 (평생 목표)
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, '목표 제목을 입력하세요'), 
        '건강한 삶'
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '목표 설명을 입력하세요'), 
        '평생에 걸친 건강 관리'
      );

      // 평생 목표 선택
      await tester.tap(find.byType(DropdownButtonFormField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('평생').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      // 2. 하위 목표 생성 (연간 목표)
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, '목표 제목을 입력하세요'), 
        '올해 운동 목표'
      );

      // 부모 목표 선택
      await tester.tap(find.text('부모 목표 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('건강한 삶'));
      await tester.pumpAndSettle();

      // 연간 목표 선택
      await tester.tap(find.byType(DropdownButtonFormField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('연간').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      // 3. 계층 구조 확인
      expect(find.text('건강한 삶'), findsOneWidget);
      expect(find.text('올해 운동 목표'), findsOneWidget);

      // 부모 목표 탭하여 하위 목표 보기
      await tester.tap(find.byIcon(Icons.expand_more));
      await tester.pumpAndSettle();

      // 하위 목표가 표시되는지 확인
      expect(find.text('올해 운동 목표'), findsOneWidget);
    });

    testWidgets('목표 필터링 및 검색 테스트', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 여러 목표 생성
      final testGoals = [
        {'title': '일간 운동', 'type': '일간'},
        {'title': '주간 독서', 'type': '주간'},
        {'title': '월간 여행', 'type': '월간'},
      ];

      for (final goal in testGoals) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, '목표 제목을 입력하세요'), 
          goal['title']!
        );

        await tester.tap(find.byType(DropdownButtonFormField));
        await tester.pumpAndSettle();
        await tester.tap(find.text(goal['type']!).last);
        await tester.pumpAndSettle();

        await tester.tap(find.text('저장'));
        await tester.pumpAndSettle();
      }

      // 모든 목표가 표시되는지 확인
      expect(find.text('일간 운동'), findsOneWidget);
      expect(find.text('주간 독서'), findsOneWidget);
      expect(find.text('월간 여행'), findsOneWidget);

      // 1. 필터링 테스트
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // 일간 목표만 필터링
      await tester.tap(find.text('일간'));
      await tester.pumpAndSettle();

      // 일간 목표만 표시되는지 확인
      expect(find.text('일간 운동'), findsOneWidget);
      expect(find.text('주간 독서'), findsNothing);
      expect(find.text('월간 여행'), findsNothing);

      // 필터 해제
      await tester.tap(find.text('전체'));
      await tester.pumpAndSettle();

      // 2. 검색 테스트
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '운동');
      await tester.pumpAndSettle();

      // 검색 결과 확인
      expect(find.text('일간 운동'), findsOneWidget);
      expect(find.text('주간 독서'), findsNothing);
      expect(find.text('월간 여행'), findsNothing);
    });

    testWidgets('목표 삭제 및 복구 테스트', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 테스트용 목표 생성
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, '목표 제목을 입력하세요'), 
        '삭제할 목표'
      );

      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      // 목표 존재 확인
      expect(find.text('삭제할 목표'), findsOneWidget);

      // 1. 목표 삭제
      await tester.longPress(find.text('삭제할 목표'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('삭제'));
      await tester.pumpAndSettle();

      // 확인 다이얼로그
      await tester.tap(find.text('확인'));
      await tester.pumpAndSettle();

      // 목표가 삭제되었는지 확인
      expect(find.text('삭제할 목표'), findsNothing);

      // 2. Snackbar의 실행 취소 버튼 탭 (복구)
      if (find.text('실행 취소').evaluate().isNotEmpty) {
        await tester.tap(find.text('실행 취소'));
        await tester.pumpAndSettle();

        // 목표가 복구되었는지 확인
        expect(find.text('삭제할 목표'), findsOneWidget);
      }
    });

    testWidgets('다크 모드 전환 테스트', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 설정 메뉴 열기
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // 다크 모드 스위치 찾기 및 토글
      final darkModeSwitch = find.widgetWithText(SwitchListTile, '다크 모드');
      if (darkModeSwitch.evaluate().isNotEmpty) {
        await tester.tap(darkModeSwitch);
        await tester.pumpAndSettle();

        // 테마 변경 확인 (색상 체크)
        final appBarTheme = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBarTheme.backgroundColor, isNot(equals(Colors.blue)));
      }
    });

    testWidgets('알림 설정 테스트', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 알림 기능이 있는 목표 생성
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, '목표 제목을 입력하세요'), 
        '알림 테스트 목표'
      );

      // 알림 활성화
      await tester.tap(find.widgetWithText(SwitchListTile, '알림 활성화'));
      await tester.pumpAndSettle();

      // 알림 빈도 선택
      await tester.tap(find.text('알림 빈도'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('매일'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      // 알림 아이콘이 표시되는지 확인
      expect(find.byIcon(Icons.notifications_active), findsOneWidget);
    });

    testWidgets('오프라인 모드 테스트', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 네트워크 비활성화 시뮬레이션
      // (실제 구현에서는 mockito 또는 플러그인 사용)

      // 목표 생성 시도
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, '목표 제목을 입력하세요'), 
        '오프라인 목표'
      );

      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      // 오프라인 메시지 확인
      expect(find.text('오프라인 상태입니다'), findsOneWidget);
      expect(find.text('나중에 동기화됩니다'), findsOneWidget);

      // 로컬에 저장되었는지 확인
      expect(find.text('오프라인 목표'), findsOneWidget);
    });
  });
}
