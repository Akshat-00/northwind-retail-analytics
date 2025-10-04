-- Row counts (expect all > 0)
SELECT 'categories'   AS t, COUNT(*) FROM categories   UNION ALL
SELECT 'customers'    AS t, COUNT(*) FROM customers    UNION ALL
SELECT 'employees'    AS t, COUNT(*) FROM employees    UNION ALL
SELECT 'shippers'     AS t, COUNT(*) FROM shippers     UNION ALL
SELECT 'suppliers'    AS t, COUNT(*) FROM suppliers    UNION ALL
SELECT 'products'     AS t, COUNT(*) FROM products     UNION ALL
SELECT 'orders'       AS t, COUNT(*) FROM orders       UNION ALL
SELECT 'orderdetails' AS t, COUNT(*) FROM orderdetails;

