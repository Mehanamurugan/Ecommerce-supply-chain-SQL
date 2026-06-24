-- ============================================================
-- E-COMMERCE SUPPLY CHAIN ANALYTICS — SQLite
-- Phase 3: Analysis Queries (12 Queries)
-- Project by: Mehana Murugan | Data Analyst Portfolio
-- ============================================================
-- HOW TO USE:
-- Open DB Browser → Execute SQL tab → Open this file
-- Run each query one at a time (select the query + press F5)
-- ============================================================

-- ============================================================
-- QUERY 1: Total Revenue, Orders & Avg Order Value
-- Concept: Basic aggregation — KPI summary
-- Resume skill: GROUP BY, ROUND, aggregate functions
-- ============================================================
SELECT
    COUNT(DISTINCT order_id)            AS total_orders,
    ROUND(SUM(total_amount), 2)         AS total_revenue,
    ROUND(AVG(total_amount), 2)         AS avg_order_value,
    COUNT(DISTINCT customer_id)         AS unique_customers
FROM Orders
WHERE order_status = 'Delivered';


-- ============================================================
-- QUERY 2: Monthly Revenue Trend (2022–2024)
-- Concept: Time-series analysis
-- Resume skill: strftime(), GROUP BY date, ORDER BY
-- ============================================================
SELECT
    strftime('%Y-%m', order_date)       AS year_month,
    COUNT(order_id)                     AS total_orders,
    ROUND(SUM(total_amount), 2)         AS monthly_revenue,
    ROUND(AVG(total_amount), 2)         AS avg_order_value
FROM Orders
WHERE order_status = 'Delivered'
GROUP BY year_month
ORDER BY year_month;


-- ============================================================
-- QUERY 3: Revenue & Orders by Region
-- Resume skill: JOIN, GROUP BY, ORDER BY, ROUND
-- ============================================================
SELECT
    c.region,
    COUNT(DISTINCT o.order_id)          AS total_orders,
    COUNT(DISTINCT o.customer_id)       AS unique_customers,
    ROUND(SUM(o.total_amount), 2)       AS total_revenue,
    ROUND(AVG(o.total_amount), 2)       AS avg_order_value
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.region
ORDER BY total_revenue DESC;


-- ============================================================
-- QUERY 4: Top 10 Revenue-Generating Products
-- Concept: Product performance analysis
-- Resume skill: Multi-table JOIN, GROUP BY, LIMIT
-- ============================================================
SELECT p.product_id, p.product_name, p.category, p.unit_price,
    SUM(oi.quantity) AS total_units_sold,
    ROUND(SUM(oi.line_total), 2) AS total_revenue,
    ROUND(SUM(oi.line_total) - SUM(oi.quantity * p.cost_price), 2) AS total_profit,
    ROUND((SUM(oi.line_total) - SUM(oi.quantity * p.cost_price))* 100.0 / SUM(oi.line_total), 2)AS profit_margin_pct
FROM Order_Items oi JOIN Products p ON oi.product_id = p.product_id
JOIN Orders o ON oi.order_id   = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.product_id
ORDER BY total_revenue DESC LIMIT 10;


-- ============================================================
-- QUERY 5: Sales Performance by Category
-- Concept: Category-level business analysis
-- Resume skill: JOIN, GROUP BY, ROUND, calculated columns
-- ============================================================
SELECT
    p.category,
    COUNT(DISTINCT p.product_id) AS num_products,
    SUM(oi.quantity) AS total_units_sold,
    ROUND(SUM(oi.line_total), 2) AS total_revenue,
    ROUND(AVG(oi.unit_price), 2) AS avg_selling_price,
    ROUND((SUM(oi.line_total) - SUM(oi.quantity * p.cost_price))* 100.0 / SUM(oi.line_total), 2) AS profit_margin_pct
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
JOIN Orders o   ON oi.order_id   = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category
ORDER BY total_revenue DESC;


-- ============================================================
-- QUERY 6: Supplier Performance Analysis
-- Concept: Vendor/supplier evaluation
-- Resume skill: Multi-table JOIN, GROUP BY, AVG, ROUND
-- ============================================================
SELECT
    s.supplier_id,
    s.supplier_name,
    s.rating AS supplier_rating,
    COUNT(DISTINCT p.product_id) AS products_supplied,
    SUM(oi.quantity) AS total_units_sold,
    ROUND(SUM(oi.line_total), 2) AS total_revenue,
    ROUND(AVG(sh.delay_days), 2) AS avg_delivery_delay
FROM Suppliers s
JOIN Products p    ON s.supplier_id  = p.supplier_id
JOIN Order_Items oi ON p.product_id  = oi.product_id
JOIN Orders o      ON oi.order_id    = o.order_id
JOIN Shipments sh  ON o.order_id     = sh.order_id
WHERE o.order_status = 'Delivered'
GROUP BY s.supplier_id
ORDER BY total_revenue DESC;


-- ============================================================
-- QUERY 7: Delivery Performance Analysis
-- Concept: Operations / logistics analysis
-- Resume skill: CASE WHEN, GROUP BY, ROUND, percentage calc
-- ============================================================
SELECT
    sh.carrier,
    COUNT(*) AS total_shipments,
    SUM(CASE WHEN sh.delay_days = 0 THEN 1 ELSE 0 END) AS on_time_deliveries,
    SUM(CASE WHEN sh.delay_days > 0 THEN 1 ELSE 0 END) AS delayed_deliveries,
    ROUND(SUM(CASE WHEN sh.delay_days = 0 THEN 1 ELSE 0 END)* 100.0 / COUNT(*), 2) AS on_time_rate_pct,
    ROUND(AVG(sh.delay_days), 2) AS avg_delay_days,
    MAX(sh.delay_days) AS max_delay_days
FROM Shipments sh
WHERE sh.delivery_status = 'Delivered'
GROUP BY sh.carrier
ORDER BY on_time_rate_pct DESC;


-- ============================================================
-- QUERY 8: Return Rate Analysis by Category & Reason
-- Concept: Quality / returns analysis
-- Resume skill: JOIN, GROUP BY, subquery, percentage calc
-- ============================================================
SELECT
    p.category,
    r.return_reason,
    COUNT(*) AS return_count,
    ROUND(SUM(r.refund_amount), 2) AS total_refund_amount,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Returns), 2) AS pct_of_all_returns
FROM Returns r
JOIN Products p ON r.product_id = p.product_id
GROUP BY p.category, r.return_reason
ORDER BY return_count DESC
LIMIT 15;


-- ============================================================
-- QUERY 9: Customer RFM Segmentation (using CTE)
-- Concept: Marketing analytics — who are your best customers?
-- Resume skill: CTE (WITH), CASE WHEN, date functions, ranking
-- R = Recency (how recently they bought)
-- F = Frequency (how often they buy)
-- M = Monetary (how much they spend)
-- ============================================================
WITH rfm_base AS (
    SELECT
        o.customer_id,
        c.full_name,
        c.region,
        CAST(
            julianday('2025-01-01') - julianday(MAX(o.order_date)) AS INTEGER) AS recency_days,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(o.total_amount), 2) AS monetary
    FROM Orders o JOIN Customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'Delivered'
    GROUP BY o.customer_id),rfm_scored AS (
    SELECT *,
        CASE
            WHEN recency_days <= 90  THEN 3
            WHEN recency_days <= 180 THEN 2
            ELSE 1
        END AS r_score,
        CASE
            WHEN frequency >= 10 THEN 3
            WHEN frequency >= 5  THEN 2
            ELSE 1
        END AS f_score,
        CASE
            WHEN monetary >= 50000 THEN 3
            WHEN monetary >= 20000 THEN 2
            ELSE 1
        END AS m_score
    FROM rfm_base)
SELECT
    customer_id,
    full_name,
    region,
    recency_days,
    frequency,
    monetary,
    (r_score + f_score + m_score) AS rfm_total_score,
    CASE
        WHEN (r_score + f_score + m_score) >= 8 THEN 'Champion'
        WHEN (r_score + f_score + m_score) >= 6 THEN 'Loyal Customer'
        WHEN (r_score + f_score + m_score) >= 4 THEN 'Potential Loyalist'
        ELSE 'At Risk'
    END AS customer_segment
FROM rfm_scored
ORDER BY rfm_total_score DESC
LIMIT 20;


-- ============================================================
-- QUERY 10: RFM Segment Summary
-- Concept: How many customers in each segment?
-- Resume skill: CTE chaining, GROUP BY on derived column
-- ============================================================
WITH rfm_base AS (
    SELECT
        o.customer_id,
        CAST(julianday('2025-01-01') - julianday(MAX(o.order_date)) AS INTEGER) AS recency_days,
        COUNT(DISTINCT o.order_id)  AS frequency,
        ROUND(SUM(o.total_amount),2) AS monetary
    FROM Orders o
    WHERE o.order_status = 'Delivered'
    GROUP BY o.customer_id
),
rfm_scored AS (
    SELECT *,
        CASE WHEN recency_days<=90 THEN 3 WHEN recency_days<=180 THEN 2 ELSE 1 END AS r_score,
        CASE WHEN frequency>=10   THEN 3 WHEN frequency>=5      THEN 2 ELSE 1 END AS f_score,
        CASE WHEN monetary>=50000 THEN 3 WHEN monetary>=20000   THEN 2 ELSE 1 END AS m_score
    FROM rfm_base
),
rfm_segmented AS (
    SELECT *,
        CASE
            WHEN (r_score+f_score+m_score) >= 8 THEN 'Champion'
            WHEN (r_score+f_score+m_score) >= 6 THEN 'Loyal Customer'
            WHEN (r_score+f_score+m_score) >= 4 THEN 'Potential Loyalist'
            ELSE 'At Risk'
        END AS customer_segment
    FROM rfm_scored
)
SELECT
    customer_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(frequency), 1) AS avg_orders,
    ROUND(AVG(monetary), 2) AS avg_spend,
    ROUND(AVG(recency_days), 0) AS avg_recency_days
FROM rfm_segmented
GROUP BY customer_segment
ORDER BY avg_spend DESC;


-- ============================================================
-- QUERY 11: Window Function — Sales Rank by Product per Category
-- Concept: Ranking within groups
-- Resume skill: RANK() OVER (PARTITION BY), window functions
-- ============================================================
SELECT
    p.category,
    p.product_name,
    ROUND(SUM(oi.line_total), 2) S total_revenue,
    SUM(oi.quantity) AS total_units,
    RANK() OVER (
        PARTITION BY p.category
        ORDER BY SUM(oi.line_total) DESC ) AS rank_in_category,
    ROUND(
        SUM(oi.line_total) * 100.0 / SUM(SUM(oi.line_total))
        OVER (PARTITION BY p.category), 2 ) AS pct_of_category_revenue
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
JOIN Orders o   ON oi.order_id   = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category, p.product_id
ORDER BY p.category, rank_in_category;


-- ============================================================
-- QUERY 12: Running Total Revenue by Month (Window Function)
-- Concept: Cumulative business growth tracking
-- Resume skill: SUM() OVER (ORDER BY), running totals
-- ============================================================
WITH monthly AS (
    SELECT
        strftime('%Y-%m', order_date) S year_month,
        COUNT(order_id) AS orders,
        ROUND(SUM(total_amount), 2) S monthly_revenue
    FROM Orders
    WHERE order_status = 'Delivered'
    GROUP BY year_month
)
SELECT
    year_month,
    orders,
    monthly_revenue,
    ROUND(
        SUM(monthly_revenue) OVER (
            ORDER BY year_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ), 2
    ) S running_total_revenue,
    ROUND(
        monthly_revenue * 100.0 /
        SUM(monthly_revenue) OVER (), 2
    ) AS pct_of_total_revenue
FROM monthly
ORDER BY year_month;
