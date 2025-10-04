CREATE TABLE IF NOT EXISTS mart.dim_product (
  product_key   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  product_id    INT UNIQUE NOT NULL,
  product_name  VARCHAR(50),
  unit          VARCHAR(25),
  current_price NUMERIC(10,2),
  category_key  INT REFERENCES mart.dim_category(category_key),
  supplier_key  INT REFERENCES mart.dim_supplier(supplier_key)
);

INSERT INTO mart.dim_product (
  product_id, product_name, unit, current_price, category_key, supplier_key
)
SELECT
  p.productid,
  p.productname,
  p.unit,
  p.price::NUMERIC(10,2),
  dc.category_key,
  ds.supplier_key
FROM products p
LEFT JOIN mart.dim_category dc ON dc.category_id = p.categoryid
LEFT JOIN mart.dim_supplier ds ON ds.supplier_id = p.supplierid
ON CONFLICT (product_id) DO UPDATE
SET product_name  = EXCLUDED.product_name,
    unit          = EXCLUDED.unit,
    current_price = EXCLUDED.current_price,
    category_key  = EXCLUDED.category_key,
    supplier_key  = EXCLUDED.supplier_key;

-- quick peek
SELECT COUNT(*) AS dim_product_rows FROM mart.dim_product;
SELECT * FROM mart.dim_product ORDER BY product_key LIMIT 5;
