# Supabase 설정 가이드

## 1️⃣ Supabase 프로젝트 정보 확인

### Supabase 대시보드에서 확인할 정보:

1. **프로젝트 설정** (Settings → General)
   - Project URL: `https://[PROJECT_REF].supabase.co`
   - Project Reference ID: `[PROJECT_REF]`

2. **API 설정** (Settings → API)
   - URL: `https://[PROJECT_REF].supabase.co`
   - anon public key: `eyJ...`
   - service_role key: `eyJ...` (보안상 백엔드에서만 사용)

3. **데이터베이스 설정** (Settings → Database)
   - Database URL: `postgresql://postgres:[PASSWORD]@db.[PROJECT_REF].supabase.co:5432/postgres`
   - Password: 프로젝트 생성 시 설정한 비밀번호

---

## 2️⃣ 환경변수 설정 파일

### 📄 `supabase-env-template.txt` (작성 후 삭제)

```
# Supabase 프로젝트 정보 입력 (대괄호 제거하고 실제 값 입력)

# 1. Supabase 프로젝트 URL
SUPABASE_URL=https://[PROJECT_REF].supabase.co

# 2. Supabase Anon Key (public)
SUPABASE_ANON_KEY=[YOUR_ANON_KEY]

# 3. Supabase Service Role Key (서버용, 보안 주의!)
SUPABASE_SERVICE_ROLE_KEY=[YOUR_SERVICE_ROLE_KEY]

# 4. 데이터베이스 연결 URL
DATABASE_URL=postgresql://postgres:[PASSWORD]@db.[PROJECT_REF].supabase.co:5432/postgres

# 5. Spring Profile (프로덕션용)
SPRING_PROFILES_ACTIVE=prod

# 6. Railway 포트 (Railway 자동 설정)
PORT=${{PORT}}
```

---

## 3️⃣ 작업 순서

### ✅ 1단계: 정보 수집
- [ ] Supabase 대시보드에서 PROJECT_REF 확인
- [ ] API Keys 복사 (anon, service_role)
- [ ] 데이터베이스 비밀번호 확인

### ⏳ 2단계: 파일 작성
- [ ] 위 템플릿에 실제 값 입력
- [ ] 대괄호 `[]` 모두 제거
- [ ] 값 검증 완료

### ⏳ 3단계: 백엔드 설정 적용
- [ ] application-prod.yml 업데이트
- [ ] 로컬 테스트용 설정 추가

### ⏳ 4단계: 데이터베이스 스키마 생성
- [ ] Supabase SQL 에디터에서 테이블 생성
- [ ] 초기 데이터 삽입

---

## 🔍 확인 방법

### Supabase에서 정보 찾는 방법:

1. **PROJECT_REF 확인**:
   - URL 바에서: `https://supabase.com/dashboard/project/[PROJECT_REF]`
   - Settings → General → Reference ID

2. **API Keys 확인**:
   - Settings → API → Project API keys
   - `anon public` key와 `service_role` key 복사

3. **데이터베이스 정보**:
   - Settings → Database → Connection string
   - 또는 Settings → Database → Connection pooling

---

## ⚠️ 보안 주의사항

- `service_role` key는 모든 권한을 가지므로 서버에서만 사용
- 환경변수 파일은 Git에 커밋하지 않음
- Railway 환경변수에만 설정하고 로컬 파일은 삭제

---

## 📝 다음 단계

환경변수 정보를 입력하셨으면:
1. "완료"라고 알려주세요
2. 백엔드 설정을 자동으로 업데이트합니다
3. 데이터베이스 스키마를 생성합니다