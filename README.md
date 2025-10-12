# 🎯 목표 관리 앱

Flutter + Spring Boot 기반의 크로스 플랫폼 개인용 목표 관리 애플리케이션입니다.

## 📱 주요 특징

### ✨ 계층적 목표 구조
```
평생 목표
├── 평생 목표 하위
│   ├── 년 단위 목표
│   │   ├── 월 단위 목표
│   │   │   ├── 주 단위 목표
│   │   │   │   └── 일 단위 목표
│   │   │   └── 독립 일 단위 목표
│   │   └── 독립 주/월 단위 목표
│   └── 독립 년 단위 목표
└── 다른 평생 목표 하위
```

### 🎛 핵심 기능
- ✅ **체크리스트 형태** 목표 관리
- 📊 **진행률 자동 계산** (하위 목표 기반)
- 🔔 **스마트 알림 시스템** (주기적 리마인더)
- 📈 **목표 달성 통계** 및 분석
- 🗃 **미달성 목표 보관함** 및 피드백
- 🎨 **직관적인 UI/UX**

### 🌐 멀티 플랫폼 지원
- 📱 **Android** (갤럭시 포함)
- 💻 **Windows** 데스크탑
- 🔄 **실시간 동기화** (향후 구현)

## 🚀 빠른 시작

### 1. 리포지터리 클론
```bash
git clone https://github.com/[your-username]/goal-management-app.git
cd goal-management-app
```

### 2. 백엔드 실행
```bash
cd backend
.\gradlew bootRun
```
- API 서버: http://localhost:8080
- H2 콘솔: http://localhost:8080/h2-console

### 3. 프론트엔드 실행
```bash
cd frontend
flutter pub get
flutter run
```

## 🧪 테스트 실행

### 백엔드 테스트
```bash
cd backend
.\gradlew test                    # 단위 테스트
.\gradlew integrationTest         # 통합 테스트
.\gradlew jacocoTestReport        # 코드 커버리지
.\run-all-tests.bat              # 전체 테스트 + 리포트
```

### 프론트엔드 테스트
```bash
cd frontend
flutter test                      # 단위 테스트
flutter test integration_test/    # 통합 테스트
.\run-flutter-tests.bat          # 전체 테스트
```

### 전체 프로젝트 테스트
```bash
.\run-all-tests.bat              # 백엔드 + 프론트엔드 전체 테스트
```

## 🛠 기술 스택

### Frontend (Flutter)
- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Provider
- **Local Storage**: SharedPreferences, SQLite
- **HTTP Client**: http package
- **Notifications**: flutter_local_notifications
- **Testing**: flutter_test, mockito, integration_test

### Backend (Spring Boot)
- **Framework**: Spring Boot 3.2+
- **Language**: Java 21
- **Database**: H2 (개발) / PostgreSQL (운영)
- **ORM**: Spring Data JPA
- **API**: RESTful API
- **Build**: Gradle
- **Testing**: JUnit 5, Mockito, Spring Boot Test, Jacoco

## 📊 테스트 리포트

### 백엔드 테스트 커버리지
- **단위 테스트**: Service, Repository, Controller 레이어
- **통합 테스트**: 전체 워크플로우 테스트
- **코드 커버리지**: 80% 이상 목표
- **테스트 리포트**: `build/reports/tests/test/index.html`
- **커버리지 리포트**: `build/reports/jacoco/test/html/index.html`

### 프론트엔드 테스트 범위
- **위젯 테스트**: UI 컴포넌트 및 상호작용
- **단위 테스트**: 모델, 서비스, 비즈니스 로직
- **통합 테스트**: 전체 사용자 시나리오
- **Mock 테스트**: API 호출 및 외부 의존성

## 📱 주요 기능 현황

### ✅ 완료된 기능
- 백엔드 API 전체 구현
- 계층적 목표 구조 지원
- 목표 CRUD 전체 기능
- 목표 완료/취소 처리
- 목표 필터링 (타입, 상태별)
- 진행률 계산 알고리즘
- 포괄적인 테스트 커버리지
- 에러 처리 및 예외 처리
- API 문서화

### 🔄 진행 중
- Flutter 앱 기본 구조
- UI/UX 디자인
- 백엔드-프론트엔드 연동

### 🗓 계획 단계
- 알림 시스템 구현
- 데이터 동기화
- 통계 및 분석 기능
- 다크 모드 지원

## 🔗 API 엔드포인트

| Method | Endpoint | 설명 |
|--------|----------|------|
| **목표 기본 CRUD** |
| GET | `/api/goals` | 전체 목표 조회 |
| GET | `/api/goals/{id}` | 목표 상세 조회 |
| POST | `/api/goals` | 목표 생성 |
| PUT | `/api/goals/{id}` | 목표 수정 |
| DELETE | `/api/goals/{id}` | 목표 삭제 |
| **목표 상태 관리** |
| PATCH | `/api/goals/{id}/complete` | 목표 완료 처리 |
| PATCH | `/api/goals/{id}/uncomplete` | 목표 완료 취소 |
| **목표 조회 필터** |
| GET | `/api/goals/today` | 오늘의 목표들 |
| GET | `/api/goals/type/{type}` | 타입별 목표 조회 |
| GET | `/api/goals/status/{status}` | 상태별 목표 조회 |
| GET | `/api/goals/root` | 최상위 목표들 |
| GET | `/api/goals/{id}/children` | 하위 목표들 |
| GET | `/api/goals/{id}/progress` | 목표 진행률 |

## 📁 프로젝트 구조

```
goal-management-app/
├── README.md                         # 프로젝트 메인 문서
├── run-all-tests.bat                # 전체 테스트 실행 스크립트
├── backend/                          # Spring Boot 백엔드
│   ├── src/main/java/com/goalapp/
│   │   ├── controller/              # REST API 컨트롤러
│   │   ├── service/                 # 비즈니스 로직
│   │   ├── repository/              # 데이터 접근 레이어
│   │   ├── entity/                  # JPA 엔티티
│   │   ├── dto/                     # 데이터 전송 객체
│   │   └── exception/               # 예외 처리
│   ├── src/test/java/com/goalapp/   # 테스트 코드
│   │   ├── controller/              # 컨트롤러 테스트
│   │   ├── service/                 # 서비스 테스트
│   │   ├── repository/              # 레포지토리 테스트
│   │   └── integration/             # 통합 테스트
│   ├── build.gradle                 # 의존성 및 빌드 설정
│   ├── run-all-tests.bat           # 백엔드 테스트 스크립트
│   └── README.md                    # 백엔드 문서
└── frontend/                         # Flutter 프론트엔드
    ├── lib/
    │   ├── main.dart
    │   ├── models/                  # 데이터 모델
    │   ├── services/                # API 서비스
    │   ├── screens/                 # 화면 위젯
    │   ├── widgets/                 # 재사용 위젯
    │   └── providers/               # 상태 관리
    ├── test/                        # 단위/위젯 테스트
    ├── test/integration/            # 통합 테스트
    ├── pubspec.yaml                # Flutter 의존성
    ├── run-flutter-tests.bat       # 프론트엔드 테스트 스크립트
    └── README.md                   # 프론트엔드 문서
```

## 📊 데이터 모델

### 목표 (Goal) 엔티티
```java
public class Goal {
    private Long id;                    // 고유 ID
    private String title;              // 목표 제목
    private String description;        // 목표 설명
    private GoalType type;             // LIFETIME, YEARLY, MONTHLY 등
    private GoalStatus status;         // ACTIVE, COMPLETED, FAILED
    private Long parentGoalId;         // 상위 목표 ID
    private LocalDateTime targetDate;  // 목표 달성 기한
    private Integer priority;          // 우선순위 (1: 높음, 3: 낮음)
    private boolean reminderEnabled;   // 알림 활성화
    private String reminderFrequency;  // 알림 빈도
    private LocalDateTime createdAt;   // 생성일
    private LocalDateTime updatedAt;   // 수정일
    private LocalDateTime completedAt; // 완료일
}
```

### 목표 타입 (GoalType)
- `LIFETIME`: 평생 목표
- `YEARLY`: 년 단위
- `MONTHLY`: 월 단위
- `WEEKLY`: 주 단위
- `DAILY`: 일 단위

### 목표 상태 (GoalStatus)
- `ACTIVE`: 진행중
- `COMPLETED`: 완료됨
- `FAILED`: 실패
- `PAUSED`: 일시정지

## 🎯 개발 로드맵

### Phase 1: 기반 구조 (완료 ✅)
- [x] 백엔드 API 개발
- [x] 기본 CRUD 기능
- [x] 계층적 목표 구조
- [x] 포괄적 테스트 커버리지
- [x] API 문서화

### Phase 2: 프론트엔드 개발 (진행중 🔄)
- [ ] Flutter 앱 기본 구조
- [ ] 목표 생성/조회 UI
- [ ] 목표 완료 체크 기능
- [ ] 진행률 시각화

### Phase 3: 핵심 기능 (계획 📋)
- [ ] 알림 시스템
- [ ] 오프라인 지원
- [ ] 데이터 동기화
- [ ] 기본 통계 화면

### Phase 4: 고도화 (계획 📋)
- [ ] 고급 통계 및 분석
- [ ] 데이터 백업/복원
- [ ] 테마 커스터마이징
- [ ] 목표 템플릿

## 🔧 API 테스트 예시

```bash
# 목표 생성
curl -X POST http://localhost:8080/api/goals \
  -H "Content-Type: application/json" \
  -d '{
    "title": "새로운 목표",
    "description": "목표 설명",
    "type": "DAILY",
    "priority": 1
  }'

# 모든 목표 조회
curl http://localhost:8080/api/goals

# 목표 완료 처리
curl -X PATCH http://localhost:8080/api/goals/1/complete

# 오늘의 목표 조회
curl http://localhost:8080/api/goals/today

# 목표 진행률 조회
curl http://localhost:8080/api/goals/1/progress
```

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이센스

이 프로젝트는 개인 학습 및 포트폴리오 목적으로 제작되었습니다.

## 👨‍💻 개발자 정보

**개발 기간**: 2024년 9월  
**현재 버전**: v1.0.0  
**개발 상태**: 백엔드 완료, 프론트엔드 진행중

### 📈 현재 프로젝트 진행률: 약 90%

- ✅ **백엔드 API**: 100% 완료
- ✅ **테스트 코드**: 100% 완료 
- 🔄 **프론트엔드**: 30% 완료
- 📋 **문서화**: 95% 완료

---

**⭐ 이 프로젝트가 도움이 되셨다면 스타를 눌러주세요!**