-- ============================================================
-- E-COMMERCE SUPPLY CHAIN ANALYTICS — SQLite
-- Phase 1: Data Verification Queries
-- Run these after 02_generate_data.py to confirm everything looks correct
-- ============================================================

-- 1. Row counts for all tables
SELECT 'Customers'   AS table_name, COUNT(*) AS row_count FROM Customers UNION ALL
SELECT 'Suppliers',   COUNT(*) FROM Suppliers   UNION ALL
SELECT 'Products',    COUNT(*) FROM Products    UNION ALL
SELECT 'Orders',      COUNT(*) FROM Orders      UNION ALL
SELECT 'Order_Items', COUNT(*) FROM Order_Items UNION ALL
SELECT 'Shipments',   COUNT(*) FROM Shipments   UNION ALL
SELECT 'Returns',     COUNT(*) FROM Returns;

-- 2. Sample customers
SELECT customer_id, full_name, city, region, registered_date
FROM Customers LIMIT 5;

-- 3. Products by category
SELECT category, COUNT(*) AS product_count,
       ROUND(AVG(unit_price),2) AS avg_price
FROM Products
GROUP BY category
ORDER BY avg_price DESC;

-- 4. Orders by status
SELECT order_status, COUNT(*) AS total_orders,
       ROUND(SUM(total_amount),2) AS total_revenue
FROM Orders
GROUP BY order_status;

-- 5. Orders by region (join with Customers)
SELECT c.region,
       COUNT(DISTINCT o.order_id) AS total_orders,
       ROUND(SUM(o.total_amount),2) AS total_revenue
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
GROUP BY c.region
ORDER BY total_revenue DESC;

-- 6. Shipment delivery status breakdown
SELECT delivery_status, COUNT(*) AS count,
       ROUND(AVG(delay_days),1) AS avg_delay_days
FROM Shipments
GROUP BY delivery_status;

-- 7. Top 5 best-selling products
SELECT p.product_name, p.category,
       SUM(oi.quantity) AS total_qty_sold,
       ROUND(SUM(oi.line_total),2) AS total_revenue
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.product_id
ORDER BY total_qty_sold DESC
LIMIT 5;

-- 8. Return rate by category
SELECT p.category,
       COUNT(*) AS return_count,
       ROUND(COUNT(*) * 100.0 / (
           SELECT COUNT(*) FROM Returns
       ), 2) AS pct_of_all_returns
FROM Returns r
JOIN Products p ON r.product_id = p.product_id
GROUP BY p.category
ORDER BY return_count DESC;
