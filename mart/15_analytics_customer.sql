-- customer lifetime value summary
CREATE OR REPLACE VIEW mart.vw_customer_ltv AS
SELECT
  dc.customer_key,
  dc.customer_id,
  dc.customer_name,
  MIN(dd.full_date)::date                                  AS first_order_date,
  MAX(dd.full_date)::date                                  AS last_order_date,
  COUNT(DISTINCT f.order_id)                               AS orders,
  SUM(f.line_revenue)::numeric(12,2)                       AS revenue,
  (SUM(f.line_revenue)/NULLIF(COUNT(DISTINCT f.order_id),0))::numeric(12,2) AS avg_order_value,
  CASE WHEN COUNT(DISTINCT f.order_id) > 1 THEN 'Repeat' ELSE 'One-time' END AS customer_type
FROM mart.fact_order_items f
JOIN mart.dim_customer dc ON dc.customer_key = f.customer_key
JOIN mart.dim_date dd     ON dd.date_key     = f.date_key
GROUP BY 1,2,3;

-- cohort retention matrix (month-by-month)
CREATE OR REPLACE VIEW mart.vw_cohort_retention AS
WITH firsts AS (
  SELECT
    dc.customer_key,
    date_trunc('month', MIN(dd.full_date))::date AS cohort_month
  FROM mart.fact_order_items f
  JOIN mart.dim_customer dc ON dc.customer_key = f.customer_key
  JOIN mart.dim_date dd     ON dd.date_key     = f.date_key
  GROUP BY 1
),
activity AS (
  SELECT
    dc.customer_key,
    date_trunc('month', dd.full_date)::date AS order_month
  FROM mart.fact_order_items f
  JOIN mart.dim_customer dc ON dc.customer_key = f.customer_key
  JOIN mart.dim_date dd     ON dd.date_key     = f.date_key
  GROUP BY 1,2
),
cohort_sizes AS (
  SELECT cohort_month, COUNT(*) AS cohort_size
  FROM firsts
  GROUP BY 1
),
active AS (
  SELECT f.cohort_month, a.order_month, COUNT(*) AS active_customers
  FROM activity a
  JOIN firsts f USING (customer_key)
  GROUP BY 1,2
)
SELECT
  a.cohort_month,
  a.order_month,
  cs.cohort_size,
  a.active_customers,
  ROUND(100.0 * a.active_customers / NULLIF(cs.cohort_size,0), 2) AS retention_pct
FROM active a
JOIN cohort_sizes cs USING (cohort_month)
ORDER BY a.cohort_month, a.order_month;

-- quick peeks
SELECT * FROM mart.vw_customer_ltv ORDER BY revenue DESC LIMIT 10;
SELECT * FROM mart.vw_cohort_retention LIMIT 20;
