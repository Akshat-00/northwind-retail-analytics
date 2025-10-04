-- counts should match source
SELECT 'categories_src' AS t, COUNT(*) FROM categories
UNION ALL
SELECT 'dim_category'  , COUNT(*) FROM mart.dim_category
UNION ALL
SELECT 'suppliers_src' , COUNT(*) FROM suppliers
UNION ALL
SELECT 'dim_supplier'  , COUNT(*) FROM mart.dim_supplier;

-- ensure every source row mapped to a dim row (expect 0 rows)
SELECT c.categoryid
FROM categories c
LEFT JOIN mart.dim_category dc ON dc.category_id = c.categoryid
WHERE dc.category_key IS NULL;

SELECT s.supplierid
FROM suppliers s
LEFT JOIN mart.dim_supplier ds ON ds.supplier_id = s.supplierid
WHERE ds.supplier_key IS NULL;

-- peek
SELECT * FROM mart.dim_category  ORDER BY category_key  LIMIT 5;
SELECT * FROM mart.dim_supplier  ORDER BY supplier_key  LIMIT 5;
