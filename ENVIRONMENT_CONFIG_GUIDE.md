# 환경별 서버 URL 설정 가이드

## 📋 개요

Flutter 앱 실행 시 빌드 타임 환경 변수를 사용하여 자동으로 서버 URL을 선택할 수 있습니다.

---

## 🌍 사용 가능한 환경

### 1. **Local** (localhost)
- **서버 URL**: `http://localhost:8080/api`
- **사용 시나리오**: Windows 데스크톱에서 로컬 서버와 직접 통신
- **실행 방법**:
  ```bash
  flutter run -d windows --dart-define=ENV=local
  ```
  또는
  ```bash
  cd frontend
  run-local.bat
  ```

### 2. **Dev** (로컬 네트워크) - 기본값
- **서버 URL**: `http://192.168.0.11:8080/api`
- **사용 시나리오**: 같은 네트워크의 다른 기기(스마트폰, 태블릿)에서 접속
- **실행 방법**:
  ```bash
  flutter run -d windows --dart-define=ENV=dev
  ```
  또는
  ```bash
  cd frontend
  run-dev.bat
  ```

### 3. **Production** (Railway)
- **서버 URL**: `https://goal-management-app-production.up.railway.app/api`
- **사용 시나리오**: 프로덕션 서버 사용
- **실행 방법**:
  ```bash
  flutter run -d windows --dart-define=ENV=prod
  ```
  또는
  ```bash
  cd frontend
  run-prod.bat
  ```

---

## 🚀 실행 방법

### 방법 1: VSCode에서 실행

1. VSCode에서 `F5` 또는 `Run and Debug` 패널 열기
2. 원하는 환경 선택:
   - `Flutter (Local - localhost:8080)`
   - `Flutter (Dev - 192.168.0.11:8080)` ← 기본값
   - `Flutter (Production - Railway)`
3. 실행 버튼 클릭

### 방법 2: 배치 파일 사용 (Windows)

```bash
# 로컬 서버
cd frontend
run-local.bat

# 개발 서버 (기본값)
cd frontend
run-dev.bat

# 프로덕션 서버
cd frontend
run-prod.bat
```

### 방법 3: Flutter CLI 직접 사용

```bash
# 로컬 서버
flutter run -d windows --dart-define=ENV=local

# 개발 서버
flutter run -d windows --dart-define=ENV=dev

# 프로덕션 서버
flutter run -d windows --dart-define=ENV=prod
```

---

## 🔧 환경 변수 미지정 시

환경 변수를 지정하지 않으면 **기본값으로 `dev` 환경**이 사용됩니다.

```bash
flutter run -d windows
# → http://192.168.0.11:8080/api 사용
```

---

## 📱 빌드 시 환경 설정

### APK 빌드 (Android)

```bash
# 프로덕션 서버로 빌드
flutter build apk --dart-define=ENV=prod

# 개발 서버로 빌드
flutter build apk --dart-define=ENV=dev
```

### Windows 앱 빌드

```bash
# 프로덕션 서버로 빌드
flutter build windows --dart-define=ENV=prod

# 로컬 서버로 빌드
flutter build windows --dart-define=ENV=local
```

---

## 🛠️ 런타임에 서버 URL 변경

앱 실행 중에도 설정 화면에서 서버 URL을 수동으로 변경할 수 있습니다.

1. 앱 실행
2. 설정 화면 이동 (구현 예정)
3. 서버 URL 입력
4. 저장

이렇게 설정한 URL은 `SharedPreferences`에 저장되며, 빌드 타임 환경보다 우선됩니다.

---

## 📊 우선순위

서버 URL 결정 우선순위는 다음과 같습니다:

1. **사용자 설정 URL** (`SharedPreferences`에 저장된 값)
2. **빌드 타임 환경 변수** (`--dart-define=ENV=...`)
3. **기본값** (`dev` 환경)

---

## 🧪 테스트 방법

### 환경이 올바르게 설정되었는지 확인

앱 시작 시 콘솔 로그 확인:

```
[INFO] App: 앱 시작
[INFO] App: 실행 환경: local
[INFO] App: 서버 URL: http://localhost:8080/api
```

### API 연결 테스트

1. 백엔드 서버가 실행 중인지 확인
   ```bash
   cd backend
   gradlew.bat bootRun
   ```

2. Flutter 앱 실행
   ```bash
   cd frontend
   run-local.bat  # 또는 원하는 환경
   ```

3. 앱에서 데이터 로드 확인
   - 목표 목록이 표시되는지 확인
   - 루틴 페이지에서 500 에러가 발생하지 않는지 확인

---

## ⚠️ 주의사항

### 1. IP 주소 변경
로컬 네트워크 IP가 변경된 경우 `api_endpoints.dart`에서 수정 필요:

```dart
// frontend/lib/core/constants/api_endpoints.dart
static const String defaultDevBaseUrl = 'http://192.168.0.11:8080/api';
                                                // ↑ 여기를 현재 IP로 변경
```

IP 주소 확인:
```bash
ipconfig  # Windows
```

### 2. 프로덕션 서버 상태
Railway 무료 티어는 비활성 시 자동으로 중지될 수 있습니다. 프로덕션 환경 사용 전에 서버가 실행 중인지 확인하세요.

### 3. CORS 설정
프로덕션 배포 전에 백엔드의 CORS 설정을 확인하세요:
- 개발: 모든 출처 허용
- 프로덕션: Railway 도메인만 허용 (보안)

---

## 📝 파일 구조

```
goal-management-app/
├── frontend/
│   ├── .vscode/
│   │   └── launch.json          # VSCode 실행 설정
│   ├── lib/
│   │   └── core/
│   │       └── constants/
│   │           └── api_endpoints.dart  # 환경별 URL 설정
│   ├── run-local.bat            # 로컬 실행 스크립트
│   ├── run-dev.bat              # 개발 실행 스크립트
│   └── run-prod.bat             # 프로덕션 실행 스크립트
└── ENVIRONMENT_CONFIG_GUIDE.md  # 이 파일
```

---

## 🎯 빠른 시작

**가장 일반적인 사용 방법**:

1. **로컬 개발** (Windows에서 백엔드 + 프론트엔드):
   ```bash
   # 터미널 1: 백엔드 실행
   cd backend
   gradlew.bat bootRun

   # 터미널 2: 프론트엔드 실행 (localhost)
   cd frontend
   run-local.bat
   ```

2. **모바일 기기 테스트**:
   ```bash
   # 터미널 1: 백엔드 실행
   cd backend
   gradlew.bat bootRun

   # 터미널 2: 프론트엔드 실행 (로컬 네트워크)
   cd frontend
   run-dev.bat
   # 또는 Android/iOS 기기에서
   flutter run -d <device-id> --dart-define=ENV=dev
   ```

3. **프로덕션 테스트**:
   ```bash
   cd frontend
   run-prod.bat
   # 백엔드는 Railway에서 실행 중
   ```

---

## 💡 팁

- VSCode에서 `Ctrl+Shift+D`로 디버그 패널을 열고 환경을 선택하면 가장 편리합니다.
- 배치 파일(.bat)을 사용하면 명령어를 외울 필요가 없습니다.
- 개발 중에는 `dev` 또는 `local` 환경을 사용하세요.
- APK 빌드 시에는 항상 `prod` 환경을 사용하세요.
