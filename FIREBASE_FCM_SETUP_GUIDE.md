# Firebase Cloud Messaging (FCM) 설정 가이드

목표 관리 앱에 푸시 알림 기능을 추가하기 위한 Firebase FCM 설정 가이드입니다.

---

## 📋 목차

1. [Firebase 프로젝트 생성](#1-firebase-프로젝트-생성)
2. [Android 앱 등록](#2-android-앱-등록)
3. [백엔드 설정 (Spring Boot)](#3-백엔드-설정-spring-boot)
4. [프론트엔드 설정 (Flutter)](#4-프론트엔드-설정-flutter)
5. [Railway 배포 설정](#5-railway-배포-설정)
6. [테스트](#6-테스트)

---

## 1. Firebase 프로젝트 생성

### 1.1 Firebase Console 접속
1. https://console.firebase.google.com/ 접속
2. Google 계정으로 로그인

### 1.2 프로젝트 생성
1. **"프로젝트 추가"** 클릭
2. 프로젝트 이름 입력: `goal-management-app` (또는 원하는 이름)
3. Google Analytics 활성화 (선택사항, 권장)
4. 계정 선택 (기본 계정 또는 새 계정 생성)
5. **"프로젝트 만들기"** 클릭

### 1.3 결제 설정 (선택사항)
- **무료 Spark 플랜**으로도 충분 (일일 메시지 제한 있음)
- 프로덕션 배포 시 **Blaze 플랜** 권장 (종량제)

---

## 2. Android 앱 등록

### 2.1 Android 앱 추가
1. Firebase Console에서 프로젝트 선택
2. 왼쪽 메뉴에서 **"프로젝트 개요"** → **"앱 추가"** → **"Android"** 선택
3. Android 패키지 이름 입력
   - Flutter 프로젝트의 `android/app/build.gradle` 파일에서 확인
   - 예: `com.example.goal_management_app`
4. 앱 닉네임: `Goal Management App` (선택사항)
5. **"앱 등록"** 클릭

### 2.2 google-services.json 다운로드
1. Firebase Console에서 `google-services.json` 파일 다운로드
2. 파일을 다음 위치에 저장:
   ```
   frontend/android/app/google-services.json
   ```

### 2.3 .gitignore 확인
**중요**: `google-services.json`은 민감 정보를 포함하므로 Git에 커밋하면 안 됩니다!

`.gitignore` 파일에 다음 내용이 있는지 확인:
```gitignore
# Firebase
**/google-services.json
**/GoogleService-Info.plist
```

---

## 3. 백엔드 설정 (Spring Boot)

### 3.1 Firebase Admin SDK 서비스 계정 키 생성

1. Firebase Console → **"프로젝트 설정"** (톱니바퀴 아이콘)
2. **"서비스 계정"** 탭 선택
3. **"새 비공개 키 생성"** 클릭
4. JSON 파일 다운로드
5. 파일 이름을 `firebase-adminsdk.json`으로 변경
6. 다음 위치에 저장:
   ```
   backend/src/main/resources/firebase-adminsdk.json
   ```

### 3.2 .gitignore 확인
**중요**: 서비스 계정 키는 절대 Git에 커밋하면 안 됩니다!

`.gitignore` 파일에 다음 내용이 있는지 확인:
```gitignore
# Firebase Admin SDK
**/firebase-adminsdk.json
**/serviceAccountKey.json
```

### 3.3 build.gradle 의존성 추가

`backend/build.gradle` 파일에 Firebase Admin SDK 의존성 추가:

```gradle
dependencies {
    // 기존 의존성들...

    // Firebase Admin SDK
    implementation 'com.google.firebase:firebase-admin:9.2.0'
}
```

### 3.4 application.yml 설정

`backend/src/main/resources/application.yml` 파일에 Firebase 설정 추가:

```yaml
firebase:
  credentials-path: classpath:firebase-adminsdk.json
```

프로덕션 환경 (`application-prod.yml`):

```yaml
firebase:
  credentials-path: ${FIREBASE_CREDENTIALS_PATH:classpath:firebase-adminsdk.json}
```

---

## 4. 프론트엔드 설정 (Flutter)

### 4.1 pubspec.yaml 의존성 추가

`frontend/pubspec.yaml` 파일에 FCM 패키지 추가:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase 관련
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9

  # 로컬 알림 (선택사항)
  flutter_local_notifications: ^16.3.0

  # 기존 의존성들...
```

### 4.2 패키지 설치

```powershell
cd frontend
flutter pub get
```

### 4.3 Android 설정

#### 4.3.1 build.gradle (프로젝트 레벨)

`frontend/android/build.gradle` 파일 수정:

```gradle
buildscript {
    dependencies {
        // 기존 classpath들...
        classpath 'com.google.gms:google-services:4.4.0'  // 추가
    }
}
```

#### 4.3.2 build.gradle (앱 레벨)

`frontend/android/app/build.gradle` 파일 맨 아래에 추가:

```gradle
apply plugin: 'com.google.gms.google-services'
```

#### 4.3.3 AndroidManifest.xml 권한 추가

`frontend/android/app/src/main/AndroidManifest.xml` 파일에 권한 추가:

```xml
<manifest ...>
    <!-- 인터넷 권한 (이미 있을 수 있음) -->
    <uses-permission android:name="android.permission.INTERNET" />

    <!-- 푸시 알림 권한 (Android 13+) -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

    <application ...>
        <!-- 기존 내용 -->
    </application>
</manifest>
```

### 4.4 iOS 설정 (선택사항)

iOS 빌드를 계획 중이라면:
1. Firebase Console에서 iOS 앱 추가
2. `GoogleService-Info.plist` 다운로드
3. Xcode 프로젝트에 추가

---

## 5. Railway 배포 설정

### 5.1 서비스 계정 키를 Base64로 인코딩

Railway는 파일 업로드를 지원하지 않으므로, JSON 파일을 Base64로 인코딩하여 환경 변수로 설정합니다.

#### Windows (PowerShell)
```powershell
$jsonPath = "C:\workspace\goal-management-app\backend\src\main\resources\firebase-adminsdk.json"
$bytes = [System.IO.File]::ReadAllBytes($jsonPath)
$base64 = [System.Convert]::ToBase64String($bytes)
$base64 | Set-Clipboard
Write-Host "Base64 encoded and copied to clipboard!"
```

### 5.2 Railway 환경 변수 설정

1. Railway Dashboard → 프로젝트 선택
2. **"Settings"** → **"Environment Variables"** 선택
3. 다음 환경 변수 추가:

| 변수명 | 값 | 설명 |
|--------|-----|------|
| `FIREBASE_CREDENTIALS_BASE64` | (복사한 Base64 문자열) | Firebase 서비스 계정 키 (Base64) |
| `FIREBASE_CREDENTIALS_PATH` | `classpath:firebase-adminsdk.json` | Firebase 인증 파일 경로 |

### 5.3 백엔드 코드 수정 (환경 변수 지원)

Firebase 초기화 코드에서 환경 변수를 읽어 JSON 파일을 생성하도록 수정합니다.

`FirebaseConfig.java` 파일에서:
```java
// 환경 변수에서 Base64 인코딩된 JSON 읽기
String base64Credentials = System.getenv("FIREBASE_CREDENTIALS_BASE64");
if (base64Credentials != null) {
    byte[] decodedBytes = Base64.getDecoder().decode(base64Credentials);
    InputStream serviceAccount = new ByteArrayInputStream(decodedBytes);
    // Firebase 초기화...
}
```

---

## 6. 테스트

### 6.1 로컬 테스트

#### 백엔드 서버 실행
```powershell
cd backend
.\gradlew.bat bootRun
```

#### 프론트엔드 앱 실행
```powershell
cd frontend
flutter run -d windows
# 또는 Android 디바이스
flutter run
```

### 6.2 푸시 알림 테스트

#### Firebase Console에서 테스트 메시지 전송
1. Firebase Console → **"Cloud Messaging"**
2. **"첫 번째 캠페인 보내기"** 또는 **"테스트 메시지 보내기"** 클릭
3. 알림 제목 및 내용 입력
4. 대상 선택: **"FCM 등록 토큰"**
5. 앱에서 생성된 토큰 입력
6. **"테스트"** 클릭

#### 백엔드 API를 통한 테스트
```powershell
# 목표 만료 임박 알림 테스트 (수동 트리거)
Invoke-RestMethod -Uri "http://localhost:8080/api/goals/expiring-soon" -Method Get
```

### 6.3 스케줄러 테스트

스케줄러가 정상 작동하는지 로그 확인:
```
⏰ Starting scheduled task: checkAndExpireGoals
⚠️ Goal expired: '테스트 목표' (ID: 1, Due: 2025-10-21T10:00:00)
✅ Expired 1 goals successfully
```

---

## 🚨 중요 보안 사항

### 1. 민감 파일은 절대 Git에 커밋하지 마세요!
- `google-services.json`
- `firebase-adminsdk.json`
- `GoogleService-Info.plist`

### 2. .gitignore 파일에 다음 패턴 추가
```gitignore
# Firebase
**/google-services.json
**/GoogleService-Info.plist
**/firebase-adminsdk.json
**/serviceAccountKey.json
```

### 3. Railway 환경 변수 사용
- 프로덕션 환경에서는 반드시 환경 변수 사용
- Base64 인코딩으로 JSON 파일 전달

---

## 📊 비용 안내

### Firebase 무료 플랜 (Spark)
- **일일 메시지**: 무제한 (단, 초당 제한 있음)
- **월별 메시지**: 무제한
- **제약사항**:
  - Blaze 플랜 전용 기능 사용 불가
  - 높은 트래픽 시 속도 제한

### Firebase 종량제 플랜 (Blaze)
- **메시지 비용**:
  - 월 1,000만 건까지 무료
  - 이후 1,000건당 $0.10
- **예상 비용** (목표 관리 앱):
  - 사용자 100명 x 일 3회 알림 = 월 9,000건
  - 예상 비용: **$0/월** (무료 범위 내)

---

## 🔧 트러블슈팅

### 1. "google-services.json not found" 오류
- 파일 위치 확인: `frontend/android/app/google-services.json`
- 파일 권한 확인
- `flutter clean` 후 재빌드

### 2. FCM 토큰이 null
- 인터넷 연결 확인
- Firebase 프로젝트 설정 확인
- 앱 패키지 이름 일치 여부 확인

### 3. Railway 배포 시 Firebase 초기화 실패
- Base64 환경 변수 확인
- 디코딩 로직 확인
- Railway 로그에서 오류 메시지 확인

### 4. 푸시 알림이 수신되지 않음
- 앱이 백그라운드/포그라운드 상태 확인
- Firebase Console에서 메시지 전송 상태 확인
- 디바이스 알림 권한 확인

---

## 📚 참고 자료

- [Firebase Console](https://console.firebase.google.com/)
- [Firebase Admin SDK Documentation](https://firebase.google.com/docs/admin/setup)
- [firebase_messaging 패키지](https://pub.dev/packages/firebase_messaging)
- [Flutter Firebase 공식 문서](https://firebase.flutter.dev/)

---

## ✅ 체크리스트

설정 완료 여부를 확인하세요:

### Firebase Console
- [ ] Firebase 프로젝트 생성 완료
- [ ] Android 앱 등록 완료
- [ ] `google-services.json` 다운로드 완료
- [ ] 서비스 계정 키 (`firebase-adminsdk.json`) 다운로드 완료

### 백엔드 (Spring Boot)
- [ ] `build.gradle`에 Firebase Admin SDK 의존성 추가
- [ ] `firebase-adminsdk.json` 파일 배치
- [ ] `.gitignore`에 민감 파일 추가
- [ ] `FirebaseConfig.java` 생성
- [ ] `FcmService.java` 생성
- [ ] `NotificationScheduler.java` 생성

### 프론트엔드 (Flutter)
- [ ] `pubspec.yaml`에 FCM 패키지 추가
- [ ] `google-services.json` 파일 배치
- [ ] `build.gradle` (프로젝트/앱 레벨) 수정
- [ ] `AndroidManifest.xml` 권한 추가
- [ ] `FcmService.dart` 생성
- [ ] FCM 토큰 등록 로직 구현

### Railway 배포
- [ ] 서비스 계정 키 Base64 인코딩
- [ ] Railway 환경 변수 설정
- [ ] 배포 후 알림 테스트

---

**작성일**: 2025-10-22
**작성자**: Claude (Anthropic)
**버전**: 1.0
