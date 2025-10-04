-- OrderDetails should always map to an Order and a Product (should return 0 rows)
SELECT od.*
FROM orderdetails od
LEFT JOIN orders   o ON o.orderid   = od.orderid
LEFT JOIN products p ON p.productid = od.productid
WHERE o.orderid IS NULL OR p.productid IS NULL;


-- OrderDetails should always map to an Order and a Product (should return 0 rows)
SELECT od.*
FROM orderdetails od
LEFT JOIN orders   o ON o.orderid   = od.orderid
LEFT JOIN products p ON p.productid = od.productid
WHERE o.orderid IS NULL OR p.productid IS NULL;

-- Orders should map to Customer, Employee, Shipper (should return 0 rows)
SELECT o.*
FROM orders o
LEFT JOIN customers c ON c.customerid = o.customerid
LEFT JOIN employees e ON e.employeeid = o.employeeid
LEFT JOIN shippers  s ON s.shipperid  = o.shipperid
WHERE c.customerid IS NULL OR e.employeeid IS NULL OR s.shipperid IS NULL;
