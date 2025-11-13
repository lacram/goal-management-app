# Render.com 배포 가이드

## 📋 목차
1. [Render.com 소개](#rendercom-소개)
2. [배포 준비](#배포-준비)
3. [배포 단계](#배포-단계)
4. [환경 변수 설정](#환경-변수-설정)
5. [배포 후 설정](#배포-후-설정)
6. [문제 해결](#문제-해결)

---

## 📌 Render.com 소개

### 무료 티어 스펙
- **메모리**: 512MB RAM
- **CPU**: 0.1 vCPU (공유)
- **스토리지**: 제한 없음
- **대역폭**: 100GB/월
- **빌드 시간**: 500분/월
- **자동 슬립**: 15분 비활성 후 (첫 요청 시 재시작 ~30초)
- **비용**: **완전 무료**

### Railway vs Render

| 항목 | Railway (무료 종료) | Render 무료 |
|------|---------------------|-------------|
| RAM | 512MB | 512MB |
| 가격 | $5/월 크레딧 소진 | **완전 무료** |
| DB 포함 | PostgreSQL 별도 | 없음 (Supabase 사용) |
| 슬립 모드 | 없음 | 15분 후 |
| 첫 요청 지연 | 없음 | ~30초 |

---

## 🚀 배포 준비

### 1. Docker 로컬 테스트 (선택 사항)

배포 전에 로컬에서 Docker 빌드를 테스트해볼 수 있습니다.

**Docker Desktop 설치 확인**:
```powershell
docker --version
# Docker version 24.x.x 이상 필요
```

**없다면**: https://www.docker.com/products/docker-desktop 에서 설치

**로컬 빌드 테스트**:
```powershell
cd C:\workspace\goal-management-app\backend

# Docker 이미지 빌드
docker build -t goal-backend:test .

# 로컬 실행 (H2 DB 사용)
docker run -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=local \
  goal-backend:test

# API 테스트
Invoke-RestMethod -Uri "http://localhost:8080/api/goals"
```

**⚠️ 주의**: 로컬 테스트는 선택사항입니다. Docker 없이도 Render 배포 가능합니다.

### 2. GitHub에 푸시 (필수)

Render는 **GitHub 연동 필수**입니다.

```powershell
# 현재 디렉토리 확인
cd C:\workspace\goal-management-app

# Git 상태 확인
git status

# 변경사항 커밋
git add .
git commit -m "Add Render deployment config with Docker"

# GitHub에 푸시
git push origin main
```

### 3. Render.com 계정 생성

1. https://render.com 접속
2. **Sign Up** 클릭
3. **GitHub로 로그인** (권장)
4. GitHub 저장소 접근 권한 허용

---

## 📦 배포 단계

### Step 1: 새 Web Service 생성

1. Render 대시보드에서 **New +** 클릭
2. **Web Service** 선택
3. GitHub 저장소 연결:
   - **Connect a repository** 클릭
   - `goal-management-app` 선택
   - **Connect** 클릭

### Step 2: 서비스 설정

#### 기본 설정
- **Name**: `goal-management-backend`
- **Region**: `Singapore` (한국과 가장 가까움)
- **Branch**: `main`
- **Root Directory**: `backend` ⚠️ 중요!
- **Runtime**: `Docker` ⚠️ Java는 Docker 필수
- **Plan**: `Free`

#### Docker 설정
- **Dockerfile Path**: `./Dockerfile`
- Render가 자동으로 감지하고 빌드합니다
- Multi-stage build로 최적화됨:
  - Build stage: Gradle로 JAR 빌드
  - Runtime stage: 경량 JRE 21로 실행

### Step 3: 환경 변수 설정

**Environment Variables** 섹션에서 다음을 추가:

| Key | Value |
|-----|-------|
| SPRING_PROFILES_ACTIVE | `prod` |
| DATABASE_URL | `jdbc:postgresql://aws-1-ap-northeast-2.pooler.supabase.com:5432/postgres?sslmode=require` |
| DB_USERNAME | `postgres.porszbvzgosxurnhrchp` |
| DB_PASSWORD | `J8qih0ZWIvnLINZW` ⚠️ 보안 주의 |

⚠️ **보안 경고**: DB 비밀번호는 민감 정보입니다. Git에 커밋하지 마세요!

### Step 4: 배포 시작

1. **Create Web Service** 클릭
2. 자동으로 빌드 시작 (~5-10분 소요)
3. 로그 확인:
   ```
   ==> Building...
   ==> Deploying...
   ==> Your service is live 🎉
   ```

---

## 🌐 배포 후 설정

### 1. URL 확인

배포 완료 후 Render가 제공하는 URL:
```
https://goal-management-backend.onrender.com
```

### 2. API 테스트

**PowerShell에서**:
```powershell
# Health Check
Invoke-RestMethod -Uri "https://goal-management-backend.onrender.com/api/goals" -Method Get

# 첫 요청은 ~30초 소요 (슬립 모드에서 깨어남)
# 이후 요청은 정상 속도
```

### 3. CORS 설정 업데이트

`backend/src/main/java/com/goalapp/config/CorsConfig.java`:

```java
@Override
public void addCorsMappings(CorsRegistry registry) {
    registry.addMapping("/**")
            .allowedOrigins(
                "http://localhost:8080",
                "http://192.168.0.11:8080",
                "https://goal-management-backend.onrender.com"  // Render URL 추가
            )
            .allowedMethods("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS")
            .allowedHeaders("*")
            .allowCredentials(true);
}
```

### 4. 프론트엔드 URL 업데이트

`frontend/lib/core/constants/api_endpoints.dart`:

```dart
static const String _prodUrl = 'https://goal-management-backend.onrender.com';
```

### 5. Flutter APK 재빌드

```powershell
cd frontend
flutter clean
flutter pub get
flutter build apk --release
```

APK 위치: `frontend/build/app/outputs/flutter-apk/app-release.apk`

---

## 🔧 환경 변수 관리 (보안 강화)

### Render 대시보드에서 설정

1. 서비스 선택 → **Environment** 탭
2. **Add Environment Variable** 클릭
3. DB_PASSWORD를 **Secret File**로 저장 (Git에서 제거 가능)

### application-prod.yml 업데이트 (옵션)

환경 변수에서 읽도록 수정:

```yaml
spring:
  datasource:
    url: ${DATABASE_URL}
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
```

---

## ⚙️ 자동 배포 설정

### GitHub Push 시 자동 배포

Render는 기본적으로 `main` 브랜치에 푸시하면 자동 배포합니다.

```powershell
# 코드 수정 후
git add .
git commit -m "Update feature"
git push origin main

# Render에서 자동으로 재배포 시작
```

### 자동 배포 끄기 (옵션)

1. 서비스 설정 → **Settings** 탭
2. **Auto-Deploy** → `No` 선택
3. 수동 배포: **Manual Deploy** → **Deploy latest commit**

---

## 🐛 문제 해결

### 1. Docker 빌드 실패

**증상**: Build failed 에러

**해결 방법 1 - Dockerfile 확인**:
```powershell
# 로컬에서 Docker 빌드 테스트
cd backend
docker build -t goal-backend:test .

# 에러 로그 확인
```

**해결 방법 2 - Gradle 빌드 테스트**:
```powershell
# Docker 없이 로컬 빌드
cd backend
.\gradlew.bat clean build -x test

# 성공하면 Git 푸시
git add .
git commit -m "Fix build"
git push
```

**해결 방법 3 - Render 로그 확인**:
1. Render Dashboard → 서비스 선택
2. **Logs** 탭에서 빌드 실패 원인 확인
3. Java 버전, Gradle 버전 확인

### 2. 메모리 부족 (OOM)

**증상**: Application crash, Out of Memory

**해결**: Dockerfile의 JAVA_OPTS 확인 및 수정

`backend/Dockerfile` 편집:
```dockerfile
# 현재 설정: -Xmx180m (180MB)
# 필요시 증가
ENV JAVA_OPTS="-Xms48m -Xmx256m -Xss256k ..."
```

**Git 푸시 후 재배포**:
```powershell
git add backend/Dockerfile
git commit -m "Increase heap size to 256MB"
git push
```

**참고**: Render 무료 티어는 512MB RAM 제공

### 3. 데이터베이스 연결 실패

**증상**: Connection timeout, Authentication failed

**해결**:
```powershell
# 1. Supabase 연결 정보 확인
# Supabase Dashboard → Settings → Database

# 2. 환경 변수 확인
# Render Dashboard → Environment 탭

# 3. Supabase에서 Render IP 허용 (필요시)
# Supabase → Settings → Database → Connection Pooling
```

### 4. 슬립 모드로 인한 느린 첫 요청

**증상**: 15분 후 첫 요청이 ~30초 소요

**해결**:
1. **무료 방법**: 그냥 기다리기 (30초 후 정상)
2. **유료 방법** ($7/월):
   - Render → Upgrade to Starter
   - 슬립 모드 없음

**자동 깨우기 (무료 해결책)**:
```yaml
# GitHub Actions로 5분마다 핑 보내기
# .github/workflows/keep-alive.yml
name: Keep Alive
on:
  schedule:
    - cron: '*/5 * * * *'  # 5분마다 실행
jobs:
  keep-alive:
    runs-on: ubuntu-latest
    steps:
      - name: Ping Render
        run: curl https://goal-management-backend.onrender.com/api/goals
```

### 5. 로그 확인

**실시간 로그**:
1. Render 대시보드 → 서비스 선택
2. **Logs** 탭
3. 실시간 스트리밍 로그 확인

**다운로드**:
```powershell
# Render CLI 설치 (옵션)
npm install -g render-cli

# 로그 다운로드
render logs [service-id]
```

---

## 📊 모니터링

### Render 대시보드

1. **Metrics** 탭:
   - CPU 사용률
   - 메모리 사용률
   - 네트워크 트래픽

2. **Events** 탭:
   - 배포 히스토리
   - 재시작 이력
   - 에러 로그

### 외부 모니터링 (옵션)

**UptimeRobot** (무료):
1. https://uptimerobot.com 가입
2. Monitor 추가:
   - URL: `https://goal-management-backend.onrender.com/api/goals`
   - Interval: 5분
3. 다운타임 알림 설정

---

## 💰 비용 최적화

### 무료 티어 유지 팁

1. **슬립 모드 수용**:
   - 첫 요청 ~30초는 감수
   - 개인 프로젝트는 충분

2. **빌드 시간 절약**:
   - 월 500분 제한
   - 불필요한 푸시 자제
   - `./gradlew build -x test` 사용

3. **대역폭 절약**:
   - 월 100GB 제한
   - 개인 사용은 충분

### 유료 전환 고려 시점

**Starter Plan** ($7/월):
- 슬립 모드 없음
- 512MB RAM (동일)
- 무제한 빌드 시간
- 100GB 대역폭 (동일)

**Pro Plan** ($25/월):
- 2GB RAM
- 1 vCPU
- 무제한 빌드 시간
- 400GB 대역폭

---

## ✅ 배포 체크리스트

### 배포 전
- [ ] GitHub에 코드 푸시
- [ ] Supabase 연결 정보 확인
- [ ] 로컬 빌드 테스트 (`gradlew build`)

### 배포 중
- [ ] Render 서비스 생성
- [ ] Root Directory: `backend` 설정
- [ ] 환경 변수 입력
- [ ] 빌드 로그 확인

### 배포 후
- [ ] API 엔드포인트 테스트
- [ ] CORS 설정 업데이트
- [ ] 프론트엔드 URL 업데이트
- [ ] Flutter APK 재빌드
- [ ] 스마트폰 테스트

---

## 🔄 Railway에서 Render로 마이그레이션

### 1단계: 데이터 확인

**현재 Railway 데이터**는 Supabase에 있으므로 **마이그레이션 불필요**!

### 2단계: Render 배포

위의 [배포 단계](#배포-단계) 따라 진행

### 3단계: 프론트엔드 전환

```dart
// frontend/lib/core/constants/api_endpoints.dart
static const String _prodUrl = 'https://goal-management-backend.onrender.com';
```

### 4단계: Railway 서비스 삭제

1. Railway Dashboard → 프로젝트 선택
2. Settings → Delete Project
3. 과금 중지 확인

---

## 📞 도움이 필요한 경우

### Render 공식 문서
- https://render.com/docs
- https://render.com/docs/deploy-spring-boot

### 커뮤니티
- Render Discord: https://discord.gg/render
- Render Community Forum: https://community.render.com

### 이슈 발생 시
1. Render Dashboard → Logs 확인
2. 로그 캡처 후 Discord/Forum에 문의
3. Supabase 연결 정보 재확인

---

## 🎉 완료!

**배포 성공 확인**:
```powershell
# API 테스트
Invoke-RestMethod -Uri "https://goal-management-backend.onrender.com/api/goals"

# 응답 예시:
# [
#   {
#     "id": 1,
#     "title": "평생 목표",
#     "type": "LIFETIME",
#     ...
#   }
# ]
```

**프론트엔드 테스트**:
1. APK 설치
2. 모바일 데이터로 접속
3. 목표 CRUD 작업 테스트

---

**문서 버전**: 1.0
**최종 수정**: 2025-11-13
**작성자**: Claude (Anthropic)
**Railway → Render 마이그레이션 가이드**
