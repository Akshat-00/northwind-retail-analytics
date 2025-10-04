CREATE SCHEMA IF NOT EXISTS meta;

CREATE TABLE IF NOT EXISTS meta.run_log (
  run_id     BIGSERIAL PRIMARY KEY,
  started_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS meta.quality_log (
  run_id     BIGINT REFERENCES meta.run_log(run_id),
  check_name TEXT,
  status     TEXT,              -- 'PASS' or 'FAIL'
  observed   NUMERIC,
  expected   NUMERIC,
  detail     TEXT,
  checked_at TIMESTAMPTZ DEFAULT now()
);