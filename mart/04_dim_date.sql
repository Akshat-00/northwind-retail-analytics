CREATE SCHEMA IF NOT EXISTS mart;

CREATE TABLE IF NOT EXISTS mart.dim_date (
  date_key   INT PRIMARY KEY,              -- yyyymmdd
  full_date  DATE NOT NULL,
  day        INT  NOT NULL,
  month      INT  NOT NULL,
  month_name VARCHAR(9) NOT NULL,
  quarter    INT  NOT NULL,
  year       INT  NOT NULL,
  is_weekend BOOLEAN NOT NULL
);

-- build a calendar spanning order dates ± 1 year
WITH bounds AS (
  SELECT (MIN(orderdate)::date - INTERVAL '365 days') AS start_d,
         (MAX(orderdate)::date + INTERVAL '365 days') AS end_d
  FROM orders
)
INSERT INTO mart.dim_date (date_key, full_date, day, month, month_name, quarter, year, is_weekend)
SELECT (EXTRACT(YEAR  FROM d)::INT*10000
      + EXTRACT(MONTH FROM d)::INT*100
      + EXTRACT(DAY   FROM d)::INT)         AS date_key,
       d::date                               AS full_date,
       EXTRACT(DAY    FROM d)::INT           AS day,
       EXTRACT(MONTH  FROM d)::INT           AS month,
       TO_CHAR(d,'Mon')                      AS month_name,
       EXTRACT(QUARTER FROM d)::INT          AS quarter,
       EXTRACT(YEAR   FROM d)::INT           AS year,
       (EXTRACT(ISODOW FROM d) IN (6,7))     AS is_weekend
FROM bounds b,
     GENERATE_SERIES(b.start_d, b.end_d, INTERVAL '1 day') AS g(d)
ON CONFLICT (date_key) DO NOTHING;

-- quick peek
SELECT MIN(full_date) AS min_date, MAX(full_date) AS max_date, COUNT(*) AS rows FROM mart.dim_date;
