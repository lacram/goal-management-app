-- 초기 테스트 데이터
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
VALUES ('2024년 운동 계획', '주 3회 이상 운동하기', 'YEARLY', 'ACTIVE', 3, '2024-12-31 23:59:59', false, 1, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO goals (title, description, type, status, parent_goal_id, due_date, is_completed, priority, reminder_enabled, created_at, updated_at) 
VALUES ('Flutter 마스터하기', '2024년 안에 Flutter로 3개 앱 완성', 'YEARLY', 'ACTIVE', 4, '2024-12-31 23:59:59', false, 1, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 월단위 목표들
INSERT INTO goals (title, description, type, status, parent_goal_id, due_date, is_completed, priority, reminder_enabled, created_at, updated_at) 
VALUES ('3월 운동 목표', '이번 달 12회 운동하기', 'MONTHLY', 'ACTIVE', 5, '2024-03-31 23:59:59', false, 1, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO goals (title, description, type, status, parent_goal_id, due_date, is_completed, priority, reminder_enabled, created_at, updated_at) 
VALUES ('목표 관리 앱 완성', 'Flutter + Spring Boot 목표 관리 앱 개발', 'MONTHLY', 'ACTIVE', 6, '2024-03-31 23:59:59', false, 1, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 주단위 목표들
INSERT INTO goals (title, description, type, status, parent_goal_id, due_date, is_completed, priority, reminder_enabled, created_at, updated_at) 
VALUES ('이번 주 운동 3회', '월, 수, 금 헬스장 가기', 'WEEKLY', 'ACTIVE', 7, '2024-03-10 23:59:59', false, 1, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO goals (title, description, type, status, parent_goal_id, due_date, is_completed, priority, reminder_enabled, created_at, updated_at) 
VALUES ('백엔드 API 완성', '목표 CRUD API 개발 완료', 'WEEKLY', 'ACTIVE', 8, '2024-03-10 23:59:59', false, 1, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 일단위 목표들
INSERT INTO goals (title, description, type, status, parent_goal_id, due_date, is_completed, priority, reminder_enabled, reminder_frequency, created_at, updated_at) 
VALUES ('오늘 헬스장 가기', '1시간 근력 운동', 'DAILY', 'ACTIVE', 9, '2024-03-04 23:59:59', false, 1, true, 'DAILY', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO goals (title, description, type, status, parent_goal_id, due_date, is_completed, priority, reminder_enabled, reminder_frequency, created_at, updated_at) 
VALUES ('Controller 작성', 'GoalController REST API 구현', 'DAILY', 'COMPLETED', 10, '2024-03-04 23:59:59', true, 1, false, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 독립 일간 목표 (parent_goal_id = NULL)
INSERT INTO goals (title, description, type, status, parent_goal_id, due_date, is_completed, priority, reminder_enabled, reminder_frequency, created_at, updated_at) 
VALUES ('독립 일간 목표', '책 30분 읽기', 'DAILY', 'ACTIVE', NULL, '2024-03-04 23:59:59', false, 2, true, 'DAILY', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);