# Railway 배포 가이드

## 📋 준비 완료된 파일들

Railway 배포를 위한 모든 설정 파일이 준비되었습니다:
- ✅ `backend/Procfile` - Railway 실행 명령
- ✅ `backend/railway.json` - Railway 빌드 설정
- ✅ `backend/src/main/resources/application-prod.yml` - 프로덕션 DB 설정
- ✅ `.gitignore` - Git 무시 파일 목록

---

## 🚀 Railway 배포 단계

### 1단계: GitHub 계정 준비
1. https://github.com 에서 계정 만들기 (이미 있으면 패스)
2. 로그인

### 2단계: 새 GitHub Repository 만들기
1. GitHub에서 **New Repository** 클릭
2. 설정:
   - Repository name: `goal-management-app`
   - Description: `목표 관리 앱`
   - **Public** 선택 (무료 배포를 위해)
   - ❌ README, .gitignore 체크 **안함** (이미 있음)
3. **Create repository** 클릭

### 3단계: Git 저장소 초기화 및 푸시

PowerShell에서 실행:

```powershell
# 프로젝트 폴더로 이동
cd C:\workspace\goal-management-app

# Git 초기화
git init

# 모든 파일 추가
git add .

# 첫 커밋
git commit -m "Initial commit for Railway deployment"

# GitHub 원격 저장소 연결 (YOUR_USERNAME을 본인 GitHub 아이디로 변경!)
git remote add origin https://github.com/YOUR_USERNAME/goal-management-app.git

# GitHub에 푸시
git branch -M main
git push -u origin main
```

**주의**: GitHub 아이디와 비밀번호 입력 필요
- 비밀번호 대신 **Personal Access Token** 사용 필요
- Token 생성: GitHub Settings → Developer settings → Personal access tokens → Generate new token

### 4단계: Railway 가입 및 프로젝트 생성

1. **Railway 가입**
   - https://railway.app 접속
   - **Login with GitHub** 클릭
   - GitHub 계정으로 로그인

2. **새 프로젝트 생성**
   - Dashboard에서 **New Project** 클릭
   - **Deploy from GitHub repo** 선택
   - `goal-management-app` 저장소 선택
   - **Deploy Now** 클릭

3. **PostgreSQL 데이터베이스 추가**
   - 프로젝트 화면에서 **New** 클릭
   - **Database** → **Add PostgreSQL** 선택
   - 자동으로 환경 변수 연결됨

### 5단계: 환경 변수 확인

Railway는 PostgreSQL을 추가하면 자동으로 환경 변수를 설정합니다:
- `DATABASE_URL` - PostgreSQL 연결 URL
- `PGHOST` - DB 호스트
- `PGPORT` - DB 포트
- `PGUSER` - DB 사용자
- `PGPASSWORD` - DB 비밀번호
- `PGDATABASE` - DB 이름

추가로 설정할 변수 (Settings → Variables):
```
SPRING_PROFILES_ACTIVE=prod
PORT=${{PORT}}  # Railway가 자동 설정
```

### 6단계: 배포 경로 설정

1. **Settings** → **Build** 섹션
2. **Root Directory** 설정: `/backend`
3. **Save** 클릭

### 7단계: 배포 확인

1. **Deployments** 탭에서 빌드 로그 확인
2. 빌드 완료 후 **Settings** → **Networking**
3. **Generate Domain** 클릭
4. 생성된 URL 복사 (예: `https://goal-management-app-production.up.railway.app`)

### 8단계: 앱 설정 업데이트

앱의 설정 화면에서 Railway URL 입력:
```
https://your-app-name.up.railway.app/api
```

또는 `frontend/lib/core/constants/api_endpoints.dart`의 `defaultDevBaseUrl` 수정:
```dart
static const String defaultDevBaseUrl = 'https://your-app-name.up.railway.app/api';
```

---

## ✅ 배포 완료 체크리스트

- [ ] GitHub 저장소 생성
- [ ] 코드 푸시 완료
- [ ] Railway 프로젝트 생성
- [ ] PostgreSQL 데이터베이스 추가
- [ ] 환경 변수 확인
- [ ] Root Directory 설정 (`/backend`)
- [ ] 배포 성공 확인
- [ ] 도메인 생성
- [ ] 앱에서 API 연결 테스트

---

## 🔧 문제 해결

### 빌드 실패 시
1. **Deployments** 탭에서 로그 확인
2. Java 버전 확인 (Java 21 필요)
3. Gradle 빌드 명령 확인

### 데이터베이스 연결 실패 시
1. PostgreSQL 서비스가 추가되었는지 확인
2. 환경 변수 `DATABASE_URL` 확인
3. `application-prod.yml`의 DB 설정 확인

### 앱에서 연결 안됨
1. Railway 도메인이 생성되었는지 확인
2. CORS 설정 확인 (`CorsConfig.java`)
3. Railway 로그에서 서버 시작 확인

---

## 💰 비용

**Railway 무료 티어:**
- $5 무료 크레딧/월
- 목표 관리 앱 정도는 무료로 충분
- 크레딧 초과 시 자동 중지 (과금 없음)

**무료 크레딧으로 가능:**
- 약 500시간/월 실행 시간
- 충분한 데이터베이스 용량
- 무제한 요청

---

## 📱 앱 재빌드

Railway URL이 확정되면 앱을 한 번만 재빌드하면 됩니다:

```powershell
cd C:\workspace\goal-management-app\frontend
flutter build apk --release
```

APK 위치: `frontend\build\app\outputs\flutter-apk\app-release.apk`

---

## 🎉 완료!

Railway 배포가 완료되면:
- ✅ 고정 HTTPS URL 제공
- ✅ WiFi 없이 데이터로 접속 가능
- ✅ 전 세계 어디서든 접속 가능
- ✅ 자동 HTTPS (보안)
- ✅ 자동 재시작 (안정성)

---

## 다음 단계

준비가 되면 말씀해주세요:
1. Git 저장소 초기화
2. GitHub에 코드 푸시
3. Railway 배포

하나씩 단계별로 도와드리겠습니다!
