CREATE TABLE IF NOT EXISTS mart.dim_shipper (
  shipper_key  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  shipper_id   INT UNIQUE NOT NULL,
  shipper_name VARCHAR(25),
  phone        VARCHAR(15)
);

INSERT INTO mart.dim_shipper (shipper_id, shipper_name, phone)
SELECT s.shipperid, s.shippername, s.phone
FROM shippers s
ON CONFLICT (shipper_id) DO UPDATE
SET shipper_name = EXCLUDED.shipper_name,
    phone        = EXCLUDED.phone;

-- quick peek
SELECT COUNT(*) AS dim_shipper_rows FROM mart.dim_shipper;
SELECT * FROM mart.dim_shipper ORDER BY shipper_key LIMIT 5;
