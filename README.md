# 🛒 E-Commerce Supply Chain Analytics — SQLite

A complete end-to-end SQL analytics project built on a realistic Indian e-commerce supply chain dataset. Designed and queried using SQLite with 7 normalized tables, 19,000+ records, and 12 business analysis queries covering beginner to advanced SQL concepts.

---

## 📌 Project Overview

| Detail | Info |
|---|---|
| **Database** | SQLite |
| **Total Records** | 19,000+ rows across 7 tables |
| **Time Period** | 2022 – 2024 |
| **Domain** | E-Commerce / Supply Chain |
| **Tools Used** | SQLite, Python, DB Browser for SQLite |

---

## 🎯 Business Questions Answered

- Which region generates the highest revenue?
- What are the top 10 revenue-generating products?
- Which supplier has the best delivery performance?
- Which carrier has the highest on-time delivery rate?
- Which product category has the highest return rate and why?
- Who are our Champion vs At-Risk customers? (RFM Segmentation)
- What is the monthly revenue trend over 3 years?
- Which product ranks #1 within each category?

---

## 🗄️ Database Schema

```
Customers ──────┐
                ├──── Orders ──── Order_Items ──── Products ──── Suppliers
Shipments ──────┘         │
                           └──── Returns
```

### Tables

| Table | Rows | Description |
|---|---|---|
| Customers | 500 | Customer demographics across 4 regions |
| Suppliers | 8 | Category-wise vendors |
| Products | 51 | 8 product categories with pricing |
| Orders | 5,000 | 3 years of order history |
| Order_Items | 8,769 | Line items per order |
| Shipments | 5,000 | Carrier and delivery tracking |
| Returns | 545 | ~8% return rate with reasons |

---

## 📂 Project Structure

```
ecommerce-supply-chain-sql/
│
├── 01_schema.sql           # CREATE TABLE statements for all 7 tables
├── 02_generate_data.py     # Python script to generate 19,000+ realistic records
├── 03_verify_data.sql      # Data verification and quality check queries
├── 04_analysis_queries.sql # 12 business analysis SQL queries
├── screenshots/            # Query result screenshots
└── README.md
```

---

## 🔍 SQL Queries — Skills Demonstrated

| # | Query | SQL Concepts |
|---|---|---|
| 1 | Total Revenue KPI Summary | COUNT, SUM, AVG, WHERE |
| 2 | Monthly Revenue Trend | strftime(), GROUP BY, ORDER BY |
| 3 | Revenue by Region | JOIN, GROUP BY, multi-table |
| 4 | Top 10 Products by Revenue | 3-table JOIN, profit calculation, LIMIT |
| 5 | Sales Performance by Category | GROUP BY, margin %, COUNT DISTINCT |
| 6 | Supplier Performance Analysis | 4-table JOIN, AVG delay |
| 7 | Delivery Performance by Carrier | CASE WHEN, conditional aggregation |
| 8 | Return Rate by Category & Reason | Subquery, GROUP BY 2 columns |
| 9 | Customer RFM Segmentation | CTE, CASE WHEN, julianday(), scoring |
| 10 | RFM Segment Summary | 3 chained CTEs, GROUP BY segment |
| 11 | Product Rank Within Category | RANK() OVER PARTITION BY, window function |
| 12 | Running Total Revenue by Month | SUM() OVER, ROWS BETWEEN, running total |




## 💡 Key Insights

- 📍 **South region** generates the highest revenue among all 4 regions
- 🏆 **HP 15 Laptop** is the top revenue-generating product
- 🚚 **BlueDart** has the highest on-time delivery rate among all carriers
- 👑 **192 Champion customers** account for a significant share of total revenue
- 📦 **Clothing** has the highest return rate at 15.96%
- 📈 Revenue shows consistent growth trend from 2022 to 2024




## 🛠️ Technical Highlights

- **Normalized schema** with proper PRIMARY KEY and FOREIGN KEY constraints
- **PRAGMA foreign_keys = ON** for referential integrity in SQLite
- **GENERATED ALWAYS AS** computed column for auto-calculated line totals
- **7 indexes** on foreign keys and date columns for query performance
- **CHECK constraints** to validate region, status, and rating values
- **Realistic Indian data** — cities, product names, carriers, and customer names

---

## 👩‍💻 About Me

**Mehana Murugan** — Data Analyst | Business Intelligence Analyst

- 📧 mehanamurugan1986@gmail.com
- 💼 [LinkedIn](https://linkedin.com/in/mehanamurugan)
- 🐙 [GitHub](https://github.com/Mehanamurugan)

---

## 📜 License

This project is open source and available under the [MIT License](LICENSE).
