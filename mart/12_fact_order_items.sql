-- fact at GRain = one order line (orderdetail)
CREATE TABLE IF NOT EXISTS mart.fact_order_items (
  order_item_key  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  orderdetail_id  INT UNIQUE NOT NULL,
  order_id        INT NOT NULL,
  date_key        INT NOT NULL REFERENCES mart.dim_date(date_key),
  customer_key    INT NOT NULL REFERENCES mart.dim_customer(customer_key),
  product_key     INT NOT NULL REFERENCES mart.dim_product(product_key),
  employee_key    INT NOT NULL REFERENCES mart.dim_employee(employee_key),
  shipper_key     INT NOT NULL REFERENCES mart.dim_shipper(shipper_key),
  quantity        INT NOT NULL,
  unit_price      NUMERIC(10,2) NOT NULL,
  discount        NUMERIC(4,3)  NOT NULL DEFAULT 0,
  line_revenue    NUMERIC(12,2) NOT NULL
);

-- load from staging view (uses product price as unit price; discount assumed 0)
INSERT INTO mart.fact_order_items (
  orderdetail_id, order_id, date_key, customer_key, product_key, employee_key, shipper_key,
  quantity, unit_price, discount, line_revenue
)
SELECT
  s.orderdetailid                           AS orderdetail_id,
  s.orderid                                 AS order_id,
  dd.date_key                               AS date_key,
  dc.customer_key,
  dp.product_key,
  de.employee_key,
  ds.shipper_key,
  s.quantity,
  s.unit_price_assumed                      AS unit_price,
  s.discount_assumed                        AS discount,
  s.line_revenue
FROM stg.order_lines s
JOIN mart.dim_customer dc ON dc.customer_id = s.customerid
JOIN mart.dim_product  dp ON dp.product_id  = s.productid
JOIN mart.dim_employee de ON de.employee_id = s.employeeid
JOIN mart.dim_shipper  ds ON ds.shipper_id  = s.shipperid
JOIN mart.dim_date    dd ON dd.full_date    = s.order_date
ON CONFLICT (orderdetail_id) DO UPDATE
SET order_id     = EXCLUDED.order_id,
    date_key     = EXCLUDED.date_key,
    customer_key = EXCLUDED.customer_key,
    product_key  = EXCLUDED.product_key,
    employee_key = EXCLUDED.employee_key,
    shipper_key  = EXCLUDED.shipper_key,
    quantity     = EXCLUDED.quantity,
    unit_price   = EXCLUDED.unit_price,
    discount     = EXCLUDED.discount,
    line_revenue = EXCLUDED.line_revenue;

-- re-runnable loads (idempotent upsert) if you reload staging later
-- (optional) uncomment to enable upsert behavior:
-- ON CONFLICT (orderdetail_id) DO UPDATE
-- SET order_id     = EXCLUDED.order_id,
--     date_key     = EXCLUDED.date_key,
--     customer_key = EXCLUDED.customer_key,
--     product_key  = EXCLUDED.product_key,
--     employee_key = EXCLUDED.employee_key,
--     shipper_key  = EXCLUDED.shipper_key,
--     quantity     = EXCLUDED.quantity,
--     unit_price   = EXCLUDED.unit_price,
--     discount     = EXCLUDED.discount,
--     line_revenue = EXCLUDED.line_revenue;

-- quick checks

-- 12a) row parity with source orderdetails (should be equal)
SELECT
  (SELECT COUNT(*) FROM orderdetails)          AS src_orderdetails_rows,
  (SELECT COUNT(*) FROM mart.fact_order_items) AS fact_rows;

-- 12b) any broken foreign keys? (expect 0 rows)
SELECT *
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
   OR ds.shipper_key  IS NULL;

-- 12c) peek
SELECT * FROM mart.fact_order_items ORDER BY order_item_key LIMIT 10;

