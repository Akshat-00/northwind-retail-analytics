CREATE TABLE IF NOT EXISTS mart.dim_employee (
  employee_key INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  employee_id  INT UNIQUE NOT NULL,
  first_name   VARCHAR(15),
  last_name    VARCHAR(15),
  full_name    VARCHAR(40),
  birth_date   DATE,
  notes        VARCHAR(1024)
);

INSERT INTO mart.dim_employee (employee_id, first_name, last_name, full_name, birth_date, notes)
SELECT
  e.employeeid,
  e.firstname,
  e.lastname,
  CONCAT(e.firstname, ' ', e.lastname),
  e.birthdate::date,
  e.notes
FROM employees e
ON CONFLICT (employee_id) DO UPDATE
SET first_name = EXCLUDED.first_name,
    last_name  = EXCLUDED.last_name,
    full_name  = EXCLUDED.full_name,
    birth_date = EXCLUDED.birth_date,
    notes      = EXCLUDED.notes;

-- quick peek
SELECT COUNT(*) AS dim_employee_rows FROM mart.dim_employee;
SELECT * FROM mart.dim_employee ORDER BY employee_key LIMIT 5;
