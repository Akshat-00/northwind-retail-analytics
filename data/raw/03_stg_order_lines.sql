-- Schemas we'll use later too
CREATE SCHEMA IF NOT EXISTS stg;
CREATE SCHEMA IF NOT EXISTS mart;
CREATE SCHEMA IF NOT EXISTS meta;

-- First staging view: one row per order line with revenue
CREATE OR REPLACE VIEW stg.order_lines AS
SELECT
  od.orderdetailid,
  od.orderid,
  o.orderdate::date               AS order_date,
  o.customerid,
  o.employeeid,
  o.shipperid,
  od.productid,
  p.productname,
  od.quantity,
  p.price::numeric(10,2)          AS unit_price_assumed,
  0::numeric(4,3)                 AS discount_assumed,
  (od.quantity * p.price)::numeric(12,2) AS line_revenue
FROM orderdetails od
JOIN orders   o ON o.orderid   = od.orderid
JOIN products p ON p.productid = od.productid;

-- Quick preview
SELECT * FROM stg.order_lines LIMIT 10;
