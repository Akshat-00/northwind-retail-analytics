-- category dimension
CREATE TABLE IF NOT EXISTS mart.dim_category (
  category_key  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  category_id   INT UNIQUE NOT NULL,
  category_name VARCHAR(25),
  description   VARCHAR(255)
);

INSERT INTO mart.dim_category (category_id, category_name, description)
SELECT c.categoryid, c.categoryname, c.description
FROM categories c
ON CONFLICT (category_id) DO UPDATE
SET category_name = EXCLUDED.category_name,
    description   = EXCLUDED.description;

-- supplier dimension
CREATE TABLE IF NOT EXISTS mart.dim_supplier (
  supplier_key   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  supplier_id    INT UNIQUE NOT NULL,
  supplier_name  VARCHAR(50),
  city           VARCHAR(20),
  country        VARCHAR(15),
  phone          VARCHAR(15)
);

INSERT INTO mart.dim_supplier (supplier_id, supplier_name, city, country, phone)
SELECT s.supplierid, s.suppliername, s.city, s.country, s.phone
FROM suppliers s
ON CONFLICT (supplier_id) DO UPDATE
SET supplier_name = EXCLUDED.supplier_name,
    city          = EXCLUDED.city,
    country       = EXCLUDED.country,
    phone         = EXCLUDED.phone;
