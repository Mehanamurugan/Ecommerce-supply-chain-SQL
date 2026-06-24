-- ============================================================
-- E-COMMERCE SUPPLY CHAIN ANALYTICS — SQLite
-- Phase 1: Database Schema
-- Project by: Mehana Murugan | Data Analyst Portfolio
-- ============================================================

-- IMPORTANT: Run this file first before any other SQL file.
-- This creates all 6 normalized tables in the correct order.

PRAGMA foreign_keys = ON;

-- ============================================================
-- TABLE 1: Customers
-- Stores customer demographics and location data
-- ============================================================
CREATE TABLE IF NOT EXISTS Customers (
    customer_id     TEXT PRIMARY KEY,           -- e.g. CUST0001
    full_name       TEXT NOT NULL,
    email           TEXT UNIQUE NOT NULL,
    phone           TEXT,
    city            TEXT NOT NULL,
    state           TEXT NOT NULL,
    region          TEXT NOT NULL               -- North / South / East / West
                    CHECK (region IN ('North','South','East','West')),
    country         TEXT NOT NULL DEFAULT 'India',
    registered_date TEXT NOT NULL               -- YYYY-MM-DD
);

-- ============================================================
-- TABLE 2: Suppliers
-- Stores supplier/vendor details
-- ============================================================
CREATE TABLE IF NOT EXISTS Suppliers (
    supplier_id     TEXT PRIMARY KEY,           -- e.g. SUP001
    supplier_name   TEXT NOT NULL,
    contact_person  TEXT,
    email           TEXT,
    phone           TEXT,
    city            TEXT NOT NULL,
    country         TEXT NOT NULL DEFAULT 'India',
    rating          REAL                        -- 1.0 to 5.0
                    CHECK (rating BETWEEN 1.0 AND 5.0)
);

-- ============================================================
-- TABLE 3: Products
-- Stores product catalog with category and pricing
-- ============================================================
CREATE TABLE IF NOT EXISTS Products (
    product_id      TEXT PRIMARY KEY,           -- e.g. PROD001
    product_name    TEXT NOT NULL,
    category        TEXT NOT NULL               -- Electronics / Clothing / etc.
                    CHECK (category IN (
                        'Electronics','Clothing','Home & Kitchen',
                        'Books','Sports','Beauty','Toys','Grocery'
                    )),
    unit_price      REAL NOT NULL,
    cost_price      REAL NOT NULL,              -- supplier cost
    stock_qty       INTEGER NOT NULL DEFAULT 0,
    supplier_id     TEXT NOT NULL,
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id)
);

-- ============================================================
-- TABLE 4: Orders
-- Master order table — one row per order
-- ============================================================
CREATE TABLE IF NOT EXISTS Orders (
    order_id        TEXT PRIMARY KEY,           -- e.g. ORD00001
    customer_id     TEXT NOT NULL,
    order_date      TEXT NOT NULL,              -- YYYY-MM-DD
    ship_mode       TEXT NOT NULL
                    CHECK (ship_mode IN (
                        'Standard','Express','Same Day','Economy'
                    )),
    order_status    TEXT NOT NULL DEFAULT 'Delivered'
                    CHECK (order_status IN (
                        'Delivered','Shipped','Pending','Cancelled'
                    )),
    payment_method  TEXT NOT NULL
                    CHECK (payment_method IN (
                        'Credit Card','Debit Card','UPI','COD','Net Banking'
                    )),
    total_amount    REAL NOT NULL,
    discount_pct    REAL DEFAULT 0.0,           -- e.g. 10.0 = 10%
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- ============================================================
-- TABLE 5: Order_Items
-- Line items for each order — one row per product per order
-- ============================================================
CREATE TABLE IF NOT EXISTS Order_Items (
    item_id         INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id        TEXT NOT NULL,
    product_id      TEXT NOT NULL,
    quantity        INTEGER NOT NULL,
    unit_price      REAL NOT NULL,              -- price at time of order
    line_total      REAL GENERATED ALWAYS AS   -- auto-calculated
                    (quantity * unit_price) STORED,
    FOREIGN KEY (order_id)    REFERENCES Orders(order_id),
    FOREIGN KEY (product_id)  REFERENCES Products(product_id)
);

-- ============================================================
-- TABLE 6: Shipments
-- Tracks delivery details for each order
-- ============================================================
CREATE TABLE IF NOT EXISTS Shipments (
    shipment_id         TEXT PRIMARY KEY,       -- e.g. SHIP00001
    order_id            TEXT NOT NULL UNIQUE,
    shipped_date        TEXT,                   -- YYYY-MM-DD
    expected_date       TEXT,                   -- YYYY-MM-DD
    delivered_date      TEXT,                   -- YYYY-MM-DD (NULL if not yet)
    carrier             TEXT NOT NULL
                        CHECK (carrier IN (
                            'BlueDart','DTDC','FedEx','Delhivery','Ecom Express'
                        )),
    tracking_number     TEXT UNIQUE,
    delivery_status     TEXT NOT NULL DEFAULT 'Delivered'
                        CHECK (delivery_status IN (
                            'Delivered','In Transit','Delayed','Returned','Lost'
                        )),
    delay_days          INTEGER DEFAULT 0,      -- 0 = on time, >0 = late
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- ============================================================
-- TABLE 7: Returns
-- Tracks returned orders with reason
-- ============================================================
CREATE TABLE IF NOT EXISTS Returns (
    return_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id        TEXT NOT NULL,
    product_id      TEXT NOT NULL,
    return_date     TEXT NOT NULL,              -- YYYY-MM-DD
    return_reason   TEXT NOT NULL
                    CHECK (return_reason IN (
                        'Defective','Wrong Item','Not as Described',
                        'Changed Mind','Damaged in Transit'
                    )),
    refund_amount   REAL NOT NULL,
    refund_status   TEXT DEFAULT 'Processed'
                    CHECK (refund_status IN (
                        'Processed','Pending','Rejected'
                    )),
    FOREIGN KEY (order_id)   REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- ============================================================
-- INDEXES — for faster query performance
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_orders_customer    ON Orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_date        ON Orders(order_date);
CREATE INDEX IF NOT EXISTS idx_order_items_order  ON Order_Items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_prod   ON Order_Items(product_id);
CREATE INDEX IF NOT EXISTS idx_shipments_order    ON Shipments(order_id);
CREATE INDEX IF NOT EXISTS idx_returns_order      ON Returns(order_id);
CREATE INDEX IF NOT EXISTS idx_products_supplier  ON Products(supplier_id);
CREATE INDEX IF NOT EXISTS idx_customers_region   ON Customers(region);

-- ============================================================
-- VERIFICATION: List all tables created
-- ============================================================
SELECT name AS table_name FROM sqlite_master
WHERE type = 'table'
ORDER BY name;
