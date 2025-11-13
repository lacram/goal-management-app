-- PostgreSQL CHECK 제약 조건 수정 스크립트
-- 목적: GoalStatus에 EXPIRED, FAILED, POSTPONED 추가

-- 1. 기존 CHECK 제약 조건 제거
ALTER TABLE goals DROP CONSTRAINT IF EXISTS goals_status_check;

-- 2. 새로운 CHECK 제약 조건 추가 (모든 상태 포함)
ALTER TABLE goals ADD CONSTRAINT goals_status_check
CHECK (status IN ('ACTIVE', 'COMPLETED', 'EXPIRED', 'ARCHIVED', 'FAILED', 'POSTPONED'));

-- 3. 확인 쿼리
SELECT constraint_name, check_clause
FROM information_schema.check_constraints
WHERE constraint_name = 'goals_status_check';

-- 완료 메시지
SELECT '✅ Status constraint updated successfully!' AS message;
