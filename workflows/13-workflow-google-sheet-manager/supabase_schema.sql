-- ========================================
-- Google Sheets 버전 관리 시스템 V2
-- AI Agent 기반 - 간소화 버전
-- ========================================

-- 기존 테이블 삭제 (새로 시작)
DROP TABLE IF EXISTS sheet_versions CASCADE;
DROP TABLE IF EXISTS change_history CASCADE;
DROP TABLE IF EXISTS restore_log CASCADE;

-- 1. 버전 저장 테이블 (UNIQUE 제약 제거)
CREATE TABLE sheet_versions (
  id BIGSERIAL PRIMARY KEY,
  sheet_id TEXT NOT NULL,
  sheet_name TEXT NOT NULL,
  version_number INTEGER NOT NULL,  -- UNIQUE 제약 없음!
  data JSONB NOT NULL,
  row_count INTEGER NOT NULL,
  data_hash TEXT NOT NULL,
  summary TEXT,  -- AI가 생성한 변경 요약
  created_at TIMESTAMPTZ DEFAULT NOW(),
  created_by TEXT DEFAULT 'n8n_automation'
);

-- 2. 변경 이력 테이블 (대폭 단순화)
CREATE TABLE change_history (
  id BIGSERIAL PRIMARY KEY,
  sheet_id TEXT NOT NULL,
  sheet_name TEXT NOT NULL,
  version_number INTEGER NOT NULL,
  summary TEXT NOT NULL,  -- AI가 생성한 변경 요약 (한글)
  is_important BOOLEAN DEFAULT FALSE,
  changed_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. 복구 로그 테이블
CREATE TABLE restore_log (
  id BIGSERIAL PRIMARY KEY,
  sheet_id TEXT NOT NULL,
  from_version_id BIGINT,  -- version_number 대신 id 사용
  to_version_id BIGINT,    -- version_number 대신 id 사용
  restored_at TIMESTAMPTZ DEFAULT NOW(),
  restored_by TEXT DEFAULT 'n8n_webhook'
);

-- ========================================
-- 인덱스 생성
-- ========================================

CREATE INDEX idx_versions_sheet ON sheet_versions(sheet_id, created_at DESC);
CREATE INDEX idx_versions_number ON sheet_versions(sheet_id, version_number DESC);
CREATE INDEX idx_changes_sheet ON change_history(sheet_id, changed_at DESC);
CREATE INDEX idx_restore_sheet ON restore_log(sheet_id, restored_at DESC);

-- ========================================
-- 유용한 뷰 (View)
-- ========================================

-- 최신 버전 조회 뷰
CREATE OR REPLACE VIEW latest_versions AS
SELECT DISTINCT ON (sheet_id)
  id,
  sheet_id,
  sheet_name,
  version_number,
  row_count,
  summary,
  created_at
FROM sheet_versions
ORDER BY sheet_id, created_at DESC;

-- 버전 히스토리 뷰
CREATE OR REPLACE VIEW version_history AS
SELECT 
  v.id,
  v.sheet_id,
  v.sheet_name,
  v.version_number,
  v.row_count,
  v.summary,
  v.created_at,
  ch.summary as change_summary,
  ch.is_important
FROM sheet_versions v
LEFT JOIN change_history ch 
  ON v.sheet_id = ch.sheet_id 
  AND v.version_number = ch.version_number
ORDER BY v.created_at DESC;

-- ========================================
-- 샘플 쿼리
-- ========================================

-- 1. 특정 시트의 최신 버전 조회
-- SELECT * FROM latest_versions 
-- WHERE sheet_id = 'YOUR_GOOGLE_SHEET_ID';

-- 2. 특정 시트의 모든 버전 목록
-- SELECT 
--   version_number, 
--   row_count, 
--   summary,
--   created_at
-- FROM sheet_versions 
-- WHERE sheet_id = 'YOUR_GOOGLE_SHEET_ID'
-- ORDER BY version_number DESC;

-- 3. 최근 중요 변경사항
-- SELECT * FROM change_history
-- WHERE sheet_id = 'YOUR_GOOGLE_SHEET_ID'
--   AND is_important = TRUE
-- ORDER BY changed_at DESC
-- LIMIT 10;

-- 4. 복구 이력
-- SELECT 
--   r.*,
--   v_from.version_number as from_version,
--   v_to.version_number as to_version
-- FROM restore_log r
-- LEFT JOIN sheet_versions v_from ON r.from_version_id = v_from.id
-- LEFT JOIN sheet_versions v_to ON r.to_version_id = v_to.id
-- WHERE r.sheet_id = 'YOUR_GOOGLE_SHEET_ID'
-- ORDER BY r.restored_at DESC;
