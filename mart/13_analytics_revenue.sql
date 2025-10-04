-- revenue by month (AOV included)
CREATE OR REPLACE VIEW mart.vw_revenue_by_month AS
SELECT
  date_trunc('month', dd.full_date)::date AS month_start,
  SUM(f.line_revenue)::numeric(12,2)      AS revenue,
  COUNT(DISTINCT f.order_id)              AS orders,
  SUM(f.quantity)                         AS units,
  (SUM(f.line_revenue) / NULLIF(COUNT(DISTINCT f.order_id),0))::numeric(12,2) AS avg_order_value
FROM mart.fact_order_items f
JOIN mart.dim_date dd ON dd.date_key = f.date_key
GROUP BY 1
ORDER BY 1;

-- revenue by category & month
CREATE OR REPLACE VIEW mart.vw_revenue_by_category_month AS
SELECT
  date_trunc('month', dd.full_date)::date AS month_start,
  dcat.category_key,
  dcat.category_name,
  SUM(f.line_revenue)::numeric(12,2)      AS revenue,
  COUNT(DISTINCT f.order_id)              AS orders,
  SUM(f.quantity)                         AS units
FROM mart.fact_order_items f
JOIN mart.dim_date     dd   ON dd.date_key     = f.date_key
JOIN mart.dim_product  dp   ON dp.product_key  = f.product_key
JOIN mart.dim_category dcat ON dcat.category_key = dp.category_key
GROUP BY 1,2,3
ORDER BY month_start, revenue DESC;

-- quick peeks
SELECT * FROM mart.vw_revenue_by_month LIMIT 12;
SELECT month_start, category_name, revenue
FROM mart.vw_revenue_by_category_month
ORDER BY month_start, revenue DESC
LIMIT 12;
