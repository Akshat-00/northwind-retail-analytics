-- all-time product leaderboard
CREATE OR REPLACE VIEW mart.vw_top_products_all_time AS
SELECT
  dp.product_key,
  dp.product_name,
  dp.current_price,
  SUM(f.quantity)                         AS units_sold,
  SUM(f.line_revenue)::numeric(12,2)      AS revenue,
  COUNT(*)                                AS order_lines,
  RANK() OVER (ORDER BY SUM(f.line_revenue) DESC) AS revenue_rank
FROM mart.fact_order_items f
JOIN mart.dim_product dp ON dp.product_key = f.product_key
GROUP BY 1,2,3
ORDER BY revenue DESC;

-- last 90 days relative to the latest date in your data
CREATE OR REPLACE VIEW mart.vw_top_products_last_90d AS
WITH maxd AS (
  SELECT MAX(dd.full_date)::date AS max_date
  FROM mart.fact_order_items f
  JOIN mart.dim_date dd ON dd.date_key = f.date_key
)
SELECT
  dp.product_key,
  dp.product_name,
  SUM(f.quantity)                         AS units_sold,
  SUM(f.line_revenue)::numeric(12,2)      AS revenue,
  RANK() OVER (ORDER BY SUM(f.line_revenue) DESC) AS revenue_rank
FROM mart.fact_order_items f
JOIN mart.dim_product dp ON dp.product_key = f.product_key
JOIN mart.dim_date dd    ON dd.date_key    = f.date_key
CROSS JOIN maxd
WHERE dd.full_date >= (maxd.max_date - INTERVAL '90 days')
GROUP BY 1,2
ORDER BY revenue DESC;

-- quick peek (top 10)
SELECT * FROM mart.vw_top_products_all_time WHERE revenue_rank <= 10;
SELECT * FROM mart.vw_top_products_last_90d WHERE revenue_rank <= 10;
