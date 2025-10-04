-- start a run
WITH newrun AS (
  INSERT INTO meta.run_log DEFAULT VALUES
  RETURNING run_id
)
-- 17a) row parity: fact vs source orderdetails
INSERT INTO meta.quality_log (run_id, check_name, status, observed, expected, detail)
SELECT run_id,
       'fact_row_parity',
       CASE WHEN fct = src THEN 'PASS' ELSE 'FAIL' END,
       fct, src,
       'fact_order_items vs orderdetails'
FROM newrun,
LATERAL (
  SELECT
    (SELECT COUNT(*) FROM mart.fact_order_items) AS fct,
    (SELECT COUNT(*) FROM orderdetails)          AS src
) s;

-- 17b) FK integrity: fact -> all dims (expect 0 breaks)
WITH newrun AS (SELECT MAX(run_id) AS run_id FROM meta.run_log),
breaks AS (
  SELECT COUNT(*) AS fk_breaks
  FROM mart.fact_order_items f
  LEFT JOIN mart.dim_date     dd ON dd.date_key     = f.date_key
  LEFT JOIN mart.dim_customer dc ON dc.customer_key = f.customer_key
  LEFT JOIN mart.dim_product  dp ON dp.product_key  = f.product_key
  LEFT JOIN mart.dim_employee de ON de.employee_key = f.employee_key
  LEFT JOIN mart.dim_shipper  ds ON ds.shipper_key  = f.shipper_key
  WHERE dd.date_key     IS NULL
     OR dc.customer_key IS NULL
     OR dp.product_key  IS NULL
     OR de.employee_key IS NULL
     OR ds.shipper_key  IS NULL
)
INSERT INTO meta.quality_log (run_id, check_name, status, observed, expected, detail)
SELECT run_id,
       'fk_integrity_fact_dims',
       CASE WHEN fk_breaks = 0 THEN 'PASS' ELSE 'FAIL' END,
       fk_breaks, 0,
       'all dims must resolve'
FROM newrun, breaks;

-- 17c) critical nulls in fact (expect 0)
WITH newrun AS (SELECT MAX(run_id) AS run_id FROM meta.run_log),
nulls AS (
  SELECT COUNT(*) AS bad_nulls
  FROM mart.fact_order_items
  WHERE date_key IS NULL OR customer_key IS NULL OR product_key IS NULL
     OR employee_key IS NULL OR shipper_key IS NULL
     OR quantity IS NULL OR unit_price IS NULL OR line_revenue IS NULL
)
INSERT INTO meta.quality_log (run_id, check_name, status, observed, expected, detail)
SELECT run_id,
       'fact_critical_nulls',
       CASE WHEN bad_nulls = 0 THEN 'PASS' ELSE 'FAIL' END,
       bad_nulls, 0,
       'must have keys and numeric metrics'
FROM newrun, nulls;

-- 17d) dim counts match source (4 pairs)
WITH newrun AS (SELECT MAX(run_id) AS run_id FROM meta.run_log)
INSERT INTO meta.quality_log (run_id, check_name, status, observed, expected, detail)
SELECT run_id, check_name,
       CASE WHEN observed = expected THEN 'PASS' ELSE 'FAIL' END,
       observed, expected, detail
FROM newrun,
LATERAL (
  VALUES
    ('dim_category_count', (SELECT COUNT(*) FROM mart.dim_category), (SELECT COUNT(*) FROM categories), 'dim vs source'),
    ('dim_supplier_count', (SELECT COUNT(*) FROM mart.dim_supplier), (SELECT COUNT(*) FROM suppliers),  'dim vs source'),
    ('dim_product_count',  (SELECT COUNT(*) FROM mart.dim_product),  (SELECT COUNT(*) FROM products),   'dim vs source'),
    ('dim_customer_count', (SELECT COUNT(*) FROM mart.dim_customer), (SELECT COUNT(*) FROM customers),  'dim vs source')
) v(check_name, observed, expected, detail);

-- peek the latest 10 quality results
SELECT *
FROM meta.quality_log
ORDER BY checked_at DESC
LIMIT 10;
