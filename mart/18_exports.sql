-- monthly revenue (simple)
CREATE OR REPLACE VIEW mart.export_revenue_by_month AS
SELECT month_start, revenue, orders, units, avg_order_value
FROM mart.vw_revenue_by_month
ORDER BY month_start;

-- category x month
CREATE OR REPLACE VIEW mart.export_revenue_by_category_month AS
SELECT month_start, category_name, revenue, orders, units
FROM mart.vw_revenue_by_category_month
ORDER BY month_start, revenue DESC;

-- top products (all-time, top 20)
CREATE OR REPLACE VIEW mart.export_top_products AS
SELECT product_name, revenue, units_sold, revenue_rank
FROM mart.vw_top_products_all_time
WHERE revenue_rank <= 20
ORDER BY revenue_rank;

-- customer LTV (top 50 by revenue)
CREATE OR REPLACE VIEW mart.export_customer_ltv AS
SELECT customer_name, first_order_date, last_order_date, orders, revenue, avg_order_value, customer_type
FROM mart.vw_customer_ltv
ORDER BY revenue DESC
LIMIT 50;
