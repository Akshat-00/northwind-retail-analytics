-- counts should match source (two pairs)
SELECT 'products_src' AS t, COUNT(*) FROM products
UNION ALL
SELECT 'dim_product' , COUNT(*) FROM mart.dim_product
UNION ALL
SELECT 'customers_src', COUNT(*) FROM customers
UNION ALL
SELECT 'dim_customer' , COUNT(*) FROM mart.dim_customer;

-- every product mapped to a product dim row (expect 0 rows)
SELECT p.productid
FROM products p
LEFT JOIN mart.dim_product dp ON dp.product_id = p.productid
WHERE dp.product_key IS NULL;

-- every customer mapped to a customer dim row (expect 0 rows)
SELECT c.customerid
FROM customers c
LEFT JOIN mart.dim_customer dc ON dc.customer_id = c.customerid
WHERE dc.customer_key IS NULL;
