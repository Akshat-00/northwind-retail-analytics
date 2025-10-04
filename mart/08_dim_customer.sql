CREATE TABLE IF NOT EXISTS mart.dim_customer (
  customer_key  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_id   INT UNIQUE NOT NULL,
  customer_name VARCHAR(50),
  contact_name  VARCHAR(50),
  address       VARCHAR(50),
  city          VARCHAR(20),
  postal_code   VARCHAR(10),
  country       VARCHAR(15)
);

INSERT INTO mart.dim_customer (
  customer_id, customer_name, contact_name, address, city, postal_code, country
)
SELECT
  c.customerid, c.customername, c.contactname,
  c.address, c.city, c.postalcode, c.country
FROM customers c
ON CONFLICT (customer_id) DO UPDATE
SET customer_name = EXCLUDED.customer_name,
    contact_name  = EXCLUDED.contact_name,
    address       = EXCLUDED.address,
    city          = EXCLUDED.city,
    postal_code   = EXCLUDED.postal_code,
    country       = EXCLUDED.country;

-- quick peek
SELECT COUNT(*) AS dim_customer_rows FROM mart.dim_customer;
SELECT * FROM mart.dim_customer ORDER BY customer_key LIMIT 5;
