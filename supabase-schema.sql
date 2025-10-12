-- Supabase 데이터베이스 스키마 및 초기 데이터
-- 이 파일을 Supabase SQL Editor에서 실행하세요

-- ===== 1. 테이블 생성 =====

-- Goal 테이블 생성
CREATE TABLE IF NOT EXISTS goals (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    type VARCHAR(50) NOT NULL CHECK (type IN ('LIFETIME', 'LIFETIME_SUB', 'YEARLY', 'MONTHLY', 'WEEKLY', 'DAILY')),
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'COMPLETED', 'ARCHIVED')),
    parent_goal_id BIGINT REFERENCES goals(id) ON DELETE CASCADE,
    due_date TIMESTAMP,
    completed_at TIMESTAMP,
    is_completed BOOLEAN NOT NULL DEFAULT false,
    priority INTEGER NOT NULL DEFAULT 1,
    reminder_enabled BOOLEAN NOT NULL DEFAULT false,
    reminder_frequency VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ===== 2. 인덱스 생성 =====

-- 부모-자식 관계 조회 최적화
CREATE INDEX IF NOT EXISTS idx_goals_parent_goal_id ON goals(parent_goal_id);

-- 타입별 조회 최적화
CREATE INDEX IF NOT EXISTS idx_goals_type ON goals(type);

-- 상태별 조회 최적화
CREATE INDEX IF NOT EXISTS idx_goals_status ON goals(status);

-- 마감일 조회 최적화
CREATE INDEX IF NOT EXISTS idx_goals_due_date ON goals(due_date);

-- ===== 3. RLS (Row Level Security) 설정 =====
-- 현재는 인증 없이 모든 접근 허용 (추후 인증 시스템 추가 시 수정)

ALTER TABLE goals ENABLE ROW LEVEL SECURITY;

-- 모든 사용자가 모든 작업 허용 (임시 정책)
CREATE POLICY "Enable all access for goals" ON goals
    FOR ALL USING (true)
    WITH CHECK (true);

-- ===== 4. 초기 테스트 데이터 삽입 =====

-- 평생 목표들
INSERT INTO goals (title, description, type, status, due_date, is_completed, priority, reminder_enabled, created_at, updated_at) 
VALUES ('건강한 삶 살기', '평생에 걸쳐 건강하고 활기찬 삶을 영위하는 것', 'LIFETIME', 'ACTIVE', NULL, false, 1, false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO goals (title, description, type, status, due_date, is_completed, priority, reminder_enabled, created_at, updated_at) 
VALUES ('개발자로 성장하기', '훌륭한 소프트웨어 개발자가 되어 사회에 기여하기', 'LIFETIME', 'ACTIVE', NULL, false, 1, false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 평생 목표 하위들
INSERT INTO goals (title, description, type, status, parent_goal_id, due_date, is_completed, priority, reminder_enabled, created_at, updated_at) 
VALUES ('체력 향상하기', '꾸준한 운동을 통해 체력과 건강 증진', 'LIFETIME_SUB', 'ACTIVE', 1, NULL, false, 1, false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO goals (title, description, type, status, parent_goal_id, due_date, is_completed, priority, reminder_enabled, created_at, updated_at) 
VALUES ('기술 역량 강화', '새로운 기술 학습과 실무 경험 쌓기', 'LIFETIME_SUB', 'ACTIVE', 2, NULL, false, 1, false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 년단위 목표들
INSERT INTO goals (title, description, type, status, parent_goal_id, due_date, is_completed, priority, reminder_enabled, created_at, updated_at) 
VALUES ('2025년 운동 계획', '주 3회 이상 운동하기', 'YEARLY', 'ACTIVE', 3, '2025-12-31 23:59:59', false, 1, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO goals (title, description, type, status, parent_goal_id, due_date, is_completed, priority, reminder_enabled, created_at, updated_at) 
VALUES ('Flutter 마스터하기', '2025년 안에 Flutter로 3개 앱 완성', 'YEARLY', 'ACTIVE', 4, '2025-12-31 23:59:59', false, 1, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 월단위 목표들
INSERT INTO goals (title, description, type, status, parent_goal_id, due_date, is_completed, priority, reminder_enabled, created_at, updated_at) 
VALUES ('10월 운동 목표', '이번 달 12회 운동하기', 'MONTHLY', 'ACTIVE', 5, '2025-10-31 23:59:59', false, 1, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO goals (title, description, type, status, parent_goal_id, due_date, is_completed, priority, reminder_enabled, created_at, updated_at) 
VALUES ('목표 관리 앱 완성', 'Flutter + Spring Boot 목표 관리 앱 개발', 'MONTHLY', 'ACTIVE', 6, '2025-10-31 23:59:59', false, 1, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 주단위 목표들
INSERT INTO goals (title, description, type, status, parent_goal_id, due_date, is_completed, priority, reminder_enabled, created_at, updated_at) 
VALUES ('이번 주 운동 3회', '월, 수, 금 헬스장 가기', 'WEEKLY', 'ACTIVE', 7, '2025-10-19 23:59:59', false, 1, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO goals (title, description, type, status, parent_goal_id, due_date, is_completed, priority, reminder_enabled, created_at, updated_at) 
VALUES ('백엔드 API 완성', '목표 CRUD API 개발 완료', 'WEEKLY', 'ACTIVE', 8, '2025-10-19 23:59:59', false, 1, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 일단위 목표들
INSERT INTO goals (title, description, type, status, parent_goal_id, due_date, is_completed, priority, reminder_enabled, reminder_frequency, created_at, updated_at) 
VALUES ('오늘 헬스장 가기', '1시간 근력 운동', 'DAILY', 'ACTIVE', 9, '2025-10-12 23:59:59', false, 1, true, 'DAILY', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO goals (title, description, type, status, parent_goal_id, due_date, is_completed, priority, reminder_enabled, reminder_frequency, created_at, updated_at) 
VALUES ('Controller 작성', 'GoalController REST API 구현', 'DAILY', 'COMPLETED', 10, '2025-10-12 23:59:59', true, 1, false, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 독립 일간 목표 (parent_goal_id = NULL)
INSERT INTO goals (title, description, type, status, parent_goal_id, due_date, is_completed, priority, reminder_enabled, reminder_frequency, created_at, updated_at) 
VALUES ('독립 일간 목표', '책 30분 읽기', 'DAILY', 'ACTIVE', NULL, '2025-10-12 23:59:59', false, 2, true, 'DAILY', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- ===== 5. 확인 쿼리 =====

-- 데이터가 정상적으로 삽입되었는지 확인
SELECT 'goals 테이블 레코드 수:' as info, COUNT(*) as count FROM goals;

-- 목표 타입별 개수 확인
SELECT type, COUNT(*) as count 
FROM goals 
GROUP BY type 
ORDER BY 
    CASE type 
        WHEN 'LIFETIME' THEN 1
        WHEN 'LIFETIME_SUB' THEN 2
        WHEN 'YEARLY' THEN 3
        WHEN 'MONTHLY' THEN 4
        WHEN 'WEEKLY' THEN 5
        WHEN 'DAILY' THEN 6
    END;

-- 완료: 스키마 생성 및 초기 데이터 삽입 완료!