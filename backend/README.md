# 목표 관리 앱 - 백엔드

Flutter + Spring Boot 기반의 개인용 목표 관리 애플리케이션의 백엔드 부분입니다.

## 🎯 주요 기능

### 계층적 목표 구조
- **평생 목표** → **평생 목표 하위** → **년/월/주/일 단위 목표**
- 독립적인 목표 설정도 가능
- 상위 목표에서 하위 목표 직접 생성

### 목표 관리
- ✅ 목표 생성, 수정, 삭제
- ✅ 목표 완료/미완료 체크
- ✅ 진행률 자동 계산
- ✅ 우선순위 설정
- ✅ 마감일 관리

### API 기능
- 📊 타입별 목표 조회
- 📊 오늘의 목표 조회
- 📊 진행중/완료된 목표 조회
- 📊 목표 통계 및 진행률

## 🛠 기술 스택

- **Framework**: Spring Boot 3.2+
- **Language**: Java 17
- **Database**: H2 (개발), PostgreSQL (운영)
- **ORM**: Spring Data JPA / Hibernate
- **Build**: Gradle
- **API**: RESTful API

## 📁 프로젝트 구조

```
backend/
├── src/main/java/com/goalapp/
│   ├── GoalManagementApplication.java  # 메인 애플리케이션
│   ├── controller/                     # REST API 컨트롤러
│   │   └── GoalController.java
│   ├── service/                        # 비즈니스 로직
│   │   └── GoalService.java
│   ├── repository/                     # 데이터 접근
│   │   └── GoalRepository.java
│   ├── entity/                         # JPA 엔티티
│   │   ├── Goal.java
│   │   ├── GoalType.java
│   │   └── GoalStatus.java
│   ├── dto/                           # 데이터 전송 객체
│   │   ├── request/
│   │   └── response/
│   └── exception/                     # 예외 처리
├── src/main/resources/
│   ├── application.yml               # 기본 설정
│   ├── application-prod.yml          # 운영 설정
│   └── data.sql                      # 초기 데이터
└── build.gradle                      # 의존성 관리
```

## 🚀 빠른 시작

### 1. 프로젝트 클론 및 실행

```bash
# 백엔드 디렉토리로 이동
cd backend

# 의존성 설치 및 애플리케이션 실행
./gradlew bootRun
```

### 2. 개발 환경 접속

- **API 서버**: http://localhost:8080
- **H2 콘솔**: http://localhost:8080/h2-console
  - JDBC URL: `jdbc:h2:mem:goaldb`
  - Username: `sa`
  - Password: (빈 값)

### 3. API 테스트

```bash
# 모든 목표 조회
curl http://localhost:8080/api/goals

# 오늘의 목표 조회
curl http://localhost:8080/api/goals/today

# 목표 생성
curl -X POST http://localhost:8080/api/goals \
  -H "Content-Type: application/json" \
  -d '{
    "title": "새로운 목표",
    "description": "목표 설명",
    "type": "DAILY",
    "priority": 1
  }'
```

## 📊 데이터 모델

### Goal Entity
```java
- id: Long                    // 고유 ID
- title: String              // 목표 제목
- description: String        // 목표 설명
- type: GoalType             // 목표 타입
- status: GoalStatus         // 목표 상태
- parentGoal: Goal           // 상위 목표
- subGoals: List<Goal>       // 하위 목표들
- dueDate: LocalDateTime     // 마감일
- isCompleted: boolean       // 완료 여부
- priority: int              // 우선순위
- reminderEnabled: boolean   // 알림 활성화
```

### GoalType Enum
- `LIFETIME`: 평생 목표
- `LIFETIME_SUB`: 평생 목표 하위
- `YEARLY`: 년 단위
- `MONTHLY`: 월 단위
- `WEEKLY`: 주 단위
- `DAILY`: 일 단위

## 🔗 주요 API 엔드포인트

| Method | URL | 설명 |
|--------|-----|------|
| GET | `/api/goals` | 모든 목표 조회 |
| GET | `/api/goals/{id}` | 목표 상세 조회 |
| POST | `/api/goals` | 목표 생성 |
| PUT | `/api/goals/{id}` | 목표 수정 |
| DELETE | `/api/goals/{id}` | 목표 삭제 |
| POST | `/api/goals/{id}/complete` | 목표 완료 |
| GET | `/api/goals/today` | 오늘의 목표 |
| GET | `/api/goals/active` | 진행중 목표 |
| GET | `/api/goals/type/{type}` | 타입별 목표 |

## 🧪 테스트

```bash
# 단위 테스트 실행
./gradlew test

# 테스트 커버리지 리포트 생성
./gradlew jacocoTestReport
```

## 📦 배포

### 개발 환경
```bash
./gradlew bootRun
```

### 운영 환경
```bash
# JAR 파일 빌드
./gradlew bootJar

# 운영 환경에서 실행
java -jar build/libs/goal-management-app-1.0.0.jar --spring.profiles.active=prod
```

## 🔧 설정

### 데이터베이스 설정
```yaml
# 개발 환경 (H2)
spring:
  datasource:
    url: jdbc:h2:mem:goaldb
    username: sa
    password: 

# 운영 환경 (PostgreSQL)
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/goaldb
    username: goal_user
    password: goal_password
```

## 📝 라이센스

이 프로젝트는 개인 학습 목적으로 제작되었습니다.

---

**개발자**: [당신의 이름]  
**프로젝트 시작일**: 2024.03  
**버전**: 1.0.0