# 목표 관리 앱 - Flutter 프론트엔드

Flutter로 개발된 목표 관리 애플리케이션의 프론트엔드입니다.

## 🎯 주요 기능

### ✨ 핵심 기능
- 🏠 **홈 대시보드**: 오늘의 목표, 진행 현황, 빠른 액션
- 📋 **목표 관리**: 계층적 목표 구조, CRUD 기능
- 📊 **진행률 추적**: 실시간 진행률 계산 및 표시
- 🔔 **알림 시스템**: 목표 리마인더 (구현 예정)
- 📈 **통계 화면**: 목표 달성 분석 (구현 예정)

### 🎨 UI/UX 특징
- **Material Design 3** 적용
- **다크/라이트 테마** 지원
- **반응형 디자인** (모바일/태블릿/데스크톱)
- **직관적인 네비게이션**
- **부드러운 애니메이션**

## 🛠 기술 스택

- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Provider
- **HTTP Client**: http package
- **Local Storage**: SharedPreferences, SQLite
- **UI Components**: Material Design 3
- **Date Formatting**: intl package

## 📁 프로젝트 구조

```
lib/
├── main.dart                          # 앱 진입점
├── core/                              # 핵심 기능
│   ├── constants/
│   │   ├── api_endpoints.dart         # API 엔드포인트
│   │   └── app_constants.dart         # 앱 상수들
│   ├── services/
│   │   └── api_service.dart           # HTTP API 서비스
│   └── theme/
│       └── app_theme.dart             # 앱 테마 설정
├── data/                              # 데이터 계층
│   ├── models/
│   │   └── goal.dart                  # 목표 데이터 모델
│   ├── providers/
│   │   └── goal_provider.dart         # 상태 관리
│   └── repositories/                  # 데이터 저장소 (예정)
└── presentation/                      # UI 계층
    ├── screens/
    │   └── home/
    │       └── home_screen.dart       # 홈 화면
    └── widgets/
        ├── common/                    # 공통 위젯
        │   ├── loading_widget.dart
        │   └── error_widget.dart
        └── goal_widgets/              # 목표 관련 위젯
            └── goal_card.dart
```

## 🚀 빠른 시작

### 사전 요구사항
- Flutter SDK 3.0.0 이상
- Dart SDK 3.0.0 이상
- Android Studio / VS Code
- 실행 중인 백엔드 서버 (http://localhost:8080)

### 설치 및 실행

1. **의존성 설치**
```bash
flutter pub get
```

2. **앱 실행**
```bash
# 개발 모드
flutter run

# 릴리즈 모드
flutter run --release
```

3. **빌드**
```bash
# Android APK
flutter build apk

# Windows 앱
flutter build windows

# 웹 앱
flutter build web
```

## 📱 화면 구성

### 현재 구현된 화면
- ✅ **홈 대시보드**
  - 시간별 인사말
  - 오늘의 목표 목록
  - 진행률 요약
  - 빠른 액션 버튼

### 구현 예정 화면
- 🔄 **목표 관리**
  - 전체 목표 리스트
  - 목표 생성/편집
  - 목표 상세보기
  - 계층적 목표 트리

- 🔄 **통계 대시보드**
  - 달성률 차트
  - 기간별 분석
  - 목표 트렌드

- 🔄 **설정**
  - 알림 설정
  - 테마 설정
  - 데이터 관리

## 🎨 디자인 시스템

### 색상 팔레트
```dart
// Primary Colors
primaryColor: #6366F1 (Indigo)
secondaryColor: #10B981 (Emerald)

// Goal Type Colors
lifetimeColor: #8B5CF6 (Purple)
yearlyColor: #3B82F6 (Blue)
monthlyColor: #06B6D4 (Cyan)
weeklyColor: #10B981 (Emerald)
dailyColor: #F59E0B (Amber)

// Status Colors
activeColor: #10B981 (Green)
completedColor: #6B7280 (Gray)
failedColor: #EF4444 (Red)
```

### 타이포그래피
- **Headline**: 큰 제목 (20-24px)
- **Title**: 섹션 제목 (16-18px)
- **Body**: 본문 텍스트 (14-16px)
- **Caption**: 보조 텍스트 (12-14px)

### 간격 체계
- **Small**: 8px
- **Medium**: 16px
- **Large**: 24px
- **XLarge**: 32px

## 🔌 API 연동

### 백엔드 서버 설정
```dart
// lib/core/constants/api_endpoints.dart
static const String baseUrl = 'http://localhost:8080/api';
```

### 주요 API 호출
```dart
// 모든 목표 조회
await apiService.getAllGoals();

// 오늘의 목표 조회
await apiService.getTodayGoals();

// 목표 생성
await apiService.createGoal(goal);

// 목표 완료 처리
await apiService.completeGoal(goalId);
```

## 🧪 테스트

### 단위 테스트 실행
```bash
flutter test
```

### 위젯 테스트 실행
```bash
flutter test test/widget_test.dart
```

### 통합 테스트 실행
```bash
flutter drive --target=test_driver/app.dart
```

## 📦 빌드 및 배포

### Android 빌드
```bash
# 디버그 APK
flutter build apk --debug

# 릴리즈 APK
flutter build apk --release

# App Bundle (Play Store)
flutter build appbundle
```

### Windows 빌드
```bash
flutter build windows --release
```

### 웹 빌드
```bash
flutter build web --release
```

## 🔧 개발 환경 설정

### VS Code 확장
- Flutter
- Dart
- Flutter Widget Snippets
- Bracket Pair Colorizer

### 유용한 개발 명령어
```bash
# 핫 리로드
r

# 핫 리스타트
R

# 디버그 정보 표시
d

# 성능 오버레이
p

# 위젯 인스펙터
i
```

## 📈 성능 최적화

### 이미 적용된 최적화
- **Provider**를 통한 효율적인 상태 관리
- **ListView.builder**를 통한 리스트 최적화
- **const 생성자** 사용으로 리빌드 최소화
- **Future.wait**를 통한 병렬 API 호출

### 향후 최적화 계획
- 이미지 캐싱
- 오프라인 지원
- 백그라운드 동기화
- 메모리 사용량 최적화

## 🐛 알려진 이슈

1. **API 연결 실패** 시 재시도 로직 개선 필요
2. **오프라인 모드** 미지원
3. **알림 기능** 미구현
4. **다국어 지원** 미구현

## 🤝 기여하기

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

### 코딩 스타일
- **Dart** 공식 스타일 가이드 준수
- **flutter analyze** 통과
- **Widget 테스트** 작성 권장

## 📄 라이센스

이 프로젝트는 개인 학습 목적으로 제작되었습니다.

## 📞 연락처

- **개발자**: [당신의 이름]
- **이메일**: [your.email@example.com]
- **GitHub**: [GitHub 링크]

---

**🚀 Flutter 3.x + Material Design 3으로 구현된 현대적인 목표 관리 앱!**