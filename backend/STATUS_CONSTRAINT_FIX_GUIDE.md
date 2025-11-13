# GoalStatus CHECK 제약 조건 수정 가이드

## 🔍 문제 상황

**에러 메시지:**
```
ERROR: new row for relation "goals" violates check constraint "goals_status_check"
Detail: Failing row contains (..., EXPIRED, ...)
```

**원인:**
- Java 코드의 `GoalStatus` enum에는 `EXPIRED`, `FAILED`, `POSTPONED` 상태가 정의되어 있음
- 하지만 PostgreSQL 데이터베이스의 CHECK 제약 조건이 `ACTIVE`, `COMPLETED`, `ARCHIVED`만 허용
- `GoalExpirationService`가 목표를 `EXPIRED` 상태로 변경하려고 할 때 제약 조건 위반 발생

---

## 🛠️ 해결 방법

### 방법 1: Railway PostgreSQL에 직접 접속 (권장)

#### 1-1. Railway 대시보드에서 데이터베이스 접속 정보 확인
1. [Railway Dashboard](https://railway.app) 로그인
2. `goal-management-app` 프로젝트 선택
3. PostgreSQL 서비스 클릭
4. "Connect" 탭에서 접속 정보 확인

#### 1-2. psql 또는 pgAdmin으로 접속
```bash
# psql 사용 (PowerShell)
psql "postgresql://postgres.porszbvzgosxurnhrchp:J8qih0ZWIvnLINZW@aws-1-ap-northeast-2.pooler.supabase.com:5432/postgres?sslmode=require"
```

#### 1-3. SQL 스크립트 실행
```sql
-- 기존 제약 조건 제거
ALTER TABLE goals DROP CONSTRAINT IF EXISTS goals_status_check;

-- 새로운 제약 조건 추가
ALTER TABLE goals ADD CONSTRAINT goals_status_check
CHECK (status IN ('ACTIVE', 'COMPLETED', 'EXPIRED', 'ARCHIVED', 'FAILED', 'POSTPONED'));

-- 확인
SELECT constraint_name, check_clause
FROM information_schema.check_constraints
WHERE constraint_name = 'goals_status_check';
```

**또는 파일 실행:**
```bash
psql "postgresql://..." -f backend/fix_status_constraint.sql
```

---

### 방법 2: Railway CLI 사용

#### 2-1. Railway CLI 설치
```powershell
# PowerShell (관리자 권한)
iwr https://railway.app/install.ps1 -useb | iex
```

#### 2-2. 로그인 및 연결
```powershell
railway login
railway link
```

#### 2-3. 데이터베이스 쉘 접속
```powershell
railway connect postgres
```

#### 2-4. SQL 실행
```sql
\i fix_status_constraint.sql
```

---

### 방법 3: Supabase 대시보드 사용 (가장 쉬움) ⭐

#### 3-1. Supabase 대시보드 접속
1. [Supabase Dashboard](https://supabase.com/dashboard) 로그인
2. 프로젝트 선택

#### 3-2. SQL Editor에서 실행
1. 왼쪽 메뉴에서 **"SQL Editor"** 클릭
2. **"New query"** 클릭
3. 다음 SQL 복사 & 붙여넣기:

```sql
-- 기존 제약 조건 제거
ALTER TABLE goals DROP CONSTRAINT IF EXISTS goals_status_check;

-- 새로운 제약 조건 추가
ALTER TABLE goals ADD CONSTRAINT goals_status_check
CHECK (status IN ('ACTIVE', 'COMPLETED', 'EXPIRED', 'ARCHIVED', 'FAILED', 'POSTPONED'));
```

4. **"Run"** 버튼 클릭
5. 성공 메시지 확인

---

### 방법 4: 애플리케이션에서 자동 수정 (임시 방법)

**주의:** 이 방법은 데이터 손실 위험이 있으므로 권장하지 않습니다.

#### 4-1. application-prod.yml 수정
```yaml
spring:
  jpa:
    hibernate:
      ddl-auto: create  # ⚠️ 기존 데이터 삭제됨!
```

#### 4-2. 애플리케이션 재시작
Railway에서 자동으로 재배포되면서 테이블 재생성

#### 4-3. 다시 원상복구
```yaml
spring:
  jpa:
    hibernate:
      ddl-auto: update
```

---

## ✅ 수정 확인

### 1. 데이터베이스에서 확인
```sql
-- CHECK 제약 조건 확인
SELECT constraint_name, check_clause
FROM information_schema.check_constraints
WHERE constraint_name = 'goals_status_check';
```

**예상 결과:**
```
constraint_name     | check_clause
--------------------+------------------------------------------------------------
goals_status_check  | ((status)::text = ANY (ARRAY['ACTIVE'::text, 'COMPLETED'::text, ...]))
```

### 2. 애플리케이션 로그 확인
```bash
# Railway 로그 확인
railway logs
```

**정상 로그:**
```
⏰ Starting scheduled task: checkAndExpireGoals
⚠️ Goal expired: '알람테스트' (ID: 37, Due: 2025-10-29T23:59:59)
✅ Expired 1 goals successfully
```

---

## 🔄 애플리케이션 재시작

수정 후 애플리케이션을 재시작하지 않아도 됩니다. 다음 스케줄링 시점에 자동으로 정상 작동합니다.

**스케줄링 시간:**
- 만료 체크: 매시간 정각 (`0 0 * * * *`)
- 보관 처리: 매일 새벽 2시 (`0 0 2 * * *`)

---

## 🚨 문제 발생 시

### 1. psql이 설치되어 있지 않은 경우
```powershell
# Chocolatey로 PostgreSQL 클라이언트 설치
choco install postgresql

# 또는 PostgreSQL 공식 사이트에서 설치
# https://www.postgresql.org/download/windows/
```

### 2. Supabase에 접속할 수 없는 경우
- Supabase 계정 확인
- 프로젝트가 일시 중지되었는지 확인
- 무료 플랜 한도 초과 여부 확인

### 3. 권한 오류가 발생하는 경우
```
ERROR: must be owner of table goals
```

**해결:**
- Supabase 대시보드에서 실행 (자동으로 올바른 권한 사용)
- 또는 데이터베이스 소유자 계정으로 접속

---

## 📝 향후 방지 방법

### 1. Flyway 또는 Liquibase 도입
```xml
<!-- pom.xml에 추가 -->
<dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-core</artifactId>
</dependency>
```

### 2. 마이그레이션 스크립트 관리
```
backend/src/main/resources/db/migration/
├── V1__Initial_schema.sql
├── V2__Add_expired_status.sql
└── V3__Add_failed_postponed_status.sql
```

### 3. CI/CD에 스키마 검증 추가
```yaml
# .github/workflows/deploy.yml
- name: Validate database schema
  run: ./gradlew flywayValidate
```

---

## 🎉 완료

수정이 완료되면:
1. ✅ `GoalExpirationService`가 정상 작동
2. ✅ 만료된 목표가 자동으로 `EXPIRED` 상태로 변경
3. ✅ 24시간 후 `ARCHIVED` 상태로 자동 보관
4. ✅ 스케줄링 에러 없음

---

**문서 작성:** 2025-11-04
**문제:** `goals_status_check` 제약 조건 위반
**해결:** CHECK 제약 조건에 EXPIRED, FAILED, POSTPONED 추가
