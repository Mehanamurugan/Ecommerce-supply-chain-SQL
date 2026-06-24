"""
E-COMMERCE SUPPLY CHAIN ANALYTICS — SQLite
Phase 1: Data Population Script
Project by: Mehana Murugan | Data Analyst Portfolio

Generates 5,000+ realistic Indian e-commerce records.
No external libraries needed — uses Python standard library only.

HOW TO RUN:
    python 02_generate_data.py

OUTPUT:
    ecommerce.db  (SQLite database with all tables populated)
"""

import sqlite3
import random
import os
from datetime import date, timedelta

# ─── Seed for reproducibility ────────────────────────────────
random.seed(42)

DB_PATH = "ecommerce.db"

# ─── Reference Data ──────────────────────────────────────────
REGIONS = {
    "North":  ["Delhi","Noida","Gurgaon","Lucknow","Jaipur","Chandigarh","Agra","Meerut"],
    "South":  ["Chennai","Bangalore","Hyderabad","Kochi","Coimbatore","Madurai","Mysore","Vizag"],
    "East":   ["Kolkata","Bhubaneswar","Patna","Guwahati","Ranchi","Siliguri","Cuttack","Dhanbad"],
    "West":   ["Mumbai","Pune","Ahmedabad","Surat","Nagpur","Nashik","Vadodara","Indore"],
}

STATES = {
    "Delhi":"Delhi", "Noida":"Uttar Pradesh", "Gurgaon":"Haryana",
    "Lucknow":"Uttar Pradesh", "Jaipur":"Rajasthan", "Chandigarh":"Punjab",
    "Agra":"Uttar Pradesh", "Meerut":"Uttar Pradesh",
    "Chennai":"Tamil Nadu", "Bangalore":"Karnataka", "Hyderabad":"Telangana",
    "Kochi":"Kerala", "Coimbatore":"Tamil Nadu", "Madurai":"Tamil Nadu",
    "Mysore":"Karnataka", "Vizag":"Andhra Pradesh",
    "Kolkata":"West Bengal", "Bhubaneswar":"Odisha", "Patna":"Bihar",
    "Guwahati":"Assam", "Ranchi":"Jharkhand", "Siliguri":"West Bengal",
    "Cuttack":"Odisha", "Dhanbad":"Jharkhand",
    "Mumbai":"Maharashtra", "Pune":"Maharashtra", "Ahmedabad":"Gujarat",
    "Surat":"Gujarat", "Nagpur":"Maharashtra", "Nashik":"Maharashtra",
    "Vadodara":"Gujarat", "Indore":"Madhya Pradesh",
}

FIRST_NAMES = [
    "Arjun","Priya","Rahul","Kavya","Vikram","Sneha","Amit","Divya",
    "Ravi","Ananya","Suresh","Pooja","Kiran","Meera","Rohit","Nisha",
    "Ajay","Lakshmi","Sanjay","Deepa","Manoj","Rekha","Vijay","Sunita",
    "Arun","Geeta","Ramesh","Uma","Sunil","Radha","Ashok","Savita",
    "Naveen","Preeti","Harish","Manjula","Dinesh","Shobha","Girish","Usha",
    "Mohan","Anita","Ganesh","Vasantha","Prakash","Saranya","Venkat","Malathi",
]
LAST_NAMES = [
    "Sharma","Patel","Kumar","Singh","Reddy","Nair","Iyer","Gupta",
    "Verma","Mehta","Joshi","Pillai","Rao","Mishra","Agarwal","Bose",
    "Chatterjee","Mukherjee","Das","Sinha","Pandey","Tiwari","Yadav","Shah",
    "Kapoor","Malhotra","Chopra","Khanna","Bhatia","Saxena","Trivedi","Desai",
]

PRODUCTS_DATA = [
    # (name, category, unit_price, cost_price)
    ("Samsung Galaxy M14","Electronics",12999,9500),
    ("Realme Narzo 50","Electronics",10499,7800),
    ("boAt Airdopes 141","Electronics",1299,700),
    ("Redmi Note 12","Electronics",14999,11000),
    ("HP 15 Laptop","Electronics",45999,38000),
    ("Sony WH-1000XM4","Electronics",24990,18000),
    ("JBL Flip 6","Electronics",8999,6000),
    ("Zebronics Webcam","Electronics",1499,900),
    ("Wipro LED Bulb 9W","Electronics",179,90),
    ("Syska Smart Plug","Electronics",699,350),
    ("Levi's Men Jeans","Clothing",2499,1200),
    ("Allen Solly Shirt","Clothing",1299,600),
    ("Biba Women Kurta","Clothing",899,400),
    ("Puma Running Shoes","Clothing",3499,1800),
    ("Adidas T-Shirt","Clothing",1199,550),
    ("Van Heusen Trousers","Clothing",1999,950),
    ("Fabindia Dupatta","Clothing",699,300),
    ("Arrow Formal Shirt","Clothing",1499,700),
    ("Prestige Pressure Cooker","Home & Kitchen",2299,1300),
    ("Philips Air Fryer","Home & Kitchen",6499,4000),
    ("Milton Water Bottle","Home & Kitchen",499,220),
    ("Bajaj Mixer Grinder","Home & Kitchen",2799,1600),
    ("Pigeon Induction Cooktop","Home & Kitchen",1999,1100),
    ("Solimo Bed Sheet","Home & Kitchen",699,300),
    ("Cello Dinner Set","Home & Kitchen",1299,650),
    ("Nilkamal Chair","Home & Kitchen",3299,2000),
    ("Atomic Habits","Books",399,150),
    ("Rich Dad Poor Dad","Books",299,120),
    ("Wings of Fire","Books",199,80),
    ("The Alchemist","Books",350,140),
    ("Python Crash Course","Books",599,250),
    ("Deep Work","Books",449,180),
    ("Cosco Cricket Bat","Sports",1499,800),
    ("Nivia Football","Sports",799,350),
    ("Yonex Badminton Kit","Sports",2199,1100),
    ("Decathlon Yoga Mat","Sports",999,450),
    ("Reebok Dumbbell Set","Sports",3499,1800),
    ("Lakme Foundation","Beauty",649,300),
    ("Mamaearth Face Wash","Beauty",299,130),
    ("Biotique Sunscreen","Beauty",349,150),
    ("L'Oreal Shampoo","Beauty",599,250),
    ("Wow Vitamin C Serum","Beauty",449,200),
    ("Lego Classic Set","Toys",2999,1600),
    ("Funskool Monopoly","Toys",999,450),
    ("Hot Wheels 10-Pack","Toys",699,300),
    ("Barbie Doll","Toys",1299,600),
    ("Tata Salt 1kg","Grocery",22,12),
    ("Aashirvaad Atta 5kg","Grocery",265,180),
    ("Fortune Sunflower Oil 1L","Grocery",145,100),
    ("Amul Butter 500g","Grocery",280,200),
    ("Parle-G Biscuits 800g","Grocery",89,55),
]

SUPPLIERS_DATA = [
    ("SUP001","TechZone Electronics","Rajesh Kumar","rajesh@techzone.in","9876543210","Mumbai"),
    ("SUP002","FashionHub India","Priya Sharma","priya@fashionhub.in","9867543211","Bangalore"),
    ("SUP003","HomeGoods Co.","Amit Patel","amit@homegoods.in","9856543212","Ahmedabad"),
    ("SUP004","BookWorld Distributors","Kavya Nair","kavya@bookworld.in","9845543213","Chennai"),
    ("SUP005","SportsPro India","Vikram Singh","vikram@sportspro.in","9834543214","Delhi"),
    ("SUP006","BeautyFirst","Sneha Reddy","sneha@beautyfirst.in","9823543215","Hyderabad"),
    ("SUP007","KidZone Toys","Mohan Das","mohan@kidzone.in","9812543216","Kolkata"),
    ("SUP008","GroceryMart","Sunita Verma","sunita@grocerymart.in","9801543217","Pune"),
]

CARRIERS = ["BlueDart","DTDC","FedEx","Delhivery","Ecom Express"]
SHIP_MODES = ["Standard","Express","Same Day","Economy"]
SHIP_WEIGHTS = [0.45, 0.30, 0.10, 0.15]  # probability weights
PAY_METHODS = ["Credit Card","Debit Card","UPI","COD","Net Banking"]
PAY_WEIGHTS  = [0.20, 0.20, 0.35, 0.15, 0.10]
ORDER_STATUS = ["Delivered","Shipped","Pending","Cancelled"]
ORDER_WEIGHTS= [0.78, 0.10, 0.05, 0.07]
RETURN_REASONS = ["Defective","Wrong Item","Not as Described","Changed Mind","Damaged in Transit"]


def rand_date(start_year=2022, end_year=2024):
    start = date(start_year, 1, 1)
    end   = date(end_year, 12, 31)
    delta = (end - start).days
    return start + timedelta(days=random.randint(0, delta))


def weighted_choice(choices, weights):
    return random.choices(choices, weights=weights, k=1)[0]


def build_db():
    if os.path.exists(DB_PATH):
        os.remove(DB_PATH)
    conn = sqlite3.connect(DB_PATH)
    cur  = conn.cursor()
    cur.executescript(open("01_schema.sql").read())
    conn.commit()

    # ── 1. Suppliers ─────────────────────────────────────────
    for sup in SUPPLIERS_DATA:
        cur.execute("""
            INSERT INTO Suppliers
              (supplier_id, supplier_name, contact_person, email, phone, city, country, rating)
            VALUES (?,?,?,?,?,?,?,?)
        """, (*sup, "India", round(random.uniform(3.2, 5.0), 1)))
    conn.commit()
    print(f"✅  Inserted {len(SUPPLIERS_DATA)} suppliers")

    # ── 2. Products (assign supplier by category) ────────────
    cat_sup = {
        "Electronics":    "SUP001",
        "Clothing":       "SUP002",
        "Home & Kitchen": "SUP003",
        "Books":          "SUP004",
        "Sports":         "SUP005",
        "Beauty":         "SUP006",
        "Toys":           "SUP007",
        "Grocery":        "SUP008",
    }
    for idx, (name, cat, price, cost) in enumerate(PRODUCTS_DATA, start=1):
        pid = f"PROD{idx:03d}"
        stock = random.randint(50, 500)
        cur.execute("""
            INSERT INTO Products
              (product_id, product_name, category, unit_price, cost_price, stock_qty, supplier_id)
            VALUES (?,?,?,?,?,?,?)
        """, (pid, name, cat, price, cost, stock, cat_sup[cat]))
    conn.commit()
    print(f"✅  Inserted {len(PRODUCTS_DATA)} products")

    # ── 3. Customers (500 unique) ─────────────────────────────
    num_customers = 500
    emails_used = set()
    for i in range(1, num_customers + 1):
        cid    = f"CUST{i:04d}"
        fname  = random.choice(FIRST_NAMES)
        lname  = random.choice(LAST_NAMES)
        name   = f"{fname} {lname}"
        region = random.choice(list(REGIONS.keys()))
        city   = random.choice(REGIONS[region])
        state  = STATES[city]
        email  = f"{fname.lower()}.{lname.lower()}{i}@email.com"
        phone  = f"9{random.randint(100000000,999999999)}"
        reg_dt = rand_date(2021, 2023).isoformat()
        cur.execute("""
            INSERT INTO Customers
              (customer_id, full_name, email, phone, city, state, region, country, registered_date)
            VALUES (?,?,?,?,?,?,?,?,?)
        """, (cid, name, email, phone, city, state, region, "India", reg_dt))
    conn.commit()
    print(f"✅  Inserted {num_customers} customers")

    # ── 4. Orders + Order_Items (5000 orders) ────────────────
    num_orders = 5000
    product_ids = [f"PROD{i:03d}" for i in range(1, len(PRODUCTS_DATA)+1)]
    product_map = {f"PROD{i:03d}": PRODUCTS_DATA[i-1][2]
                   for i in range(1, len(PRODUCTS_DATA)+1)}

    for i in range(1, num_orders + 1):
        oid        = f"ORD{i:05d}"
        cid        = f"CUST{random.randint(1, num_customers):04d}"
        order_date = rand_date(2022, 2024)
        ship_mode  = weighted_choice(SHIP_MODES, SHIP_WEIGHTS)
        status     = weighted_choice(ORDER_STATUS, ORDER_WEIGHTS)
        pay_method = weighted_choice(PAY_METHODS, PAY_WEIGHTS)
        discount   = random.choice([0, 0, 0, 5, 10, 15, 20])

        # 1 to 4 items per order
        num_items  = random.choices([1,2,3,4], weights=[0.5,0.3,0.15,0.05])[0]
        items      = random.sample(product_ids, num_items)
        total      = 0

        cur.execute("""
            INSERT INTO Orders
              (order_id, customer_id, order_date, ship_mode, order_status,
               payment_method, total_amount, discount_pct)
            VALUES (?,?,?,?,?,?,?,?)
        """, (oid, cid, order_date.isoformat(), ship_mode, status,
              pay_method, 0, discount))

        for prod_id in items:
            qty   = random.randint(1, 3)
            price = product_map[prod_id]
            total += qty * price
            cur.execute("""
                INSERT INTO Order_Items (order_id, product_id, quantity, unit_price)
                VALUES (?,?,?,?)
            """, (oid, prod_id, qty, price))

        # Apply discount to total
        total = round(total * (1 - discount / 100), 2)
        cur.execute("UPDATE Orders SET total_amount=? WHERE order_id=?", (total, oid))

    conn.commit()
    print(f"✅  Inserted {num_orders} orders with line items")

    # ── 5. Shipments ─────────────────────────────────────────
    cur.execute("SELECT order_id, order_date, ship_mode, order_status FROM Orders")
    orders = cur.fetchall()

    ship_lead = {"Standard":5, "Express":2, "Same Day":1, "Economy":8}

    for oid, odate, smode, ostatus in orders:
        sid      = f"SHIP{oid[3:]}"
        track    = f"TRK{int(oid[3:]):05d}{random.randint(100,999)}"
        carrier  = random.choice(CARRIERS)
        odt      = date.fromisoformat(odate)
        ship_dt  = odt + timedelta(days=random.randint(0,1))
        lead     = ship_lead[smode]
        exp_dt   = ship_dt + timedelta(days=lead)

        # Simulate delays
        delay = 0
        if ostatus == "Delivered":
            delay = random.choices([0,0,0,1,2,3,5], weights=[0.5,0.15,0.1,0.1,0.07,0.05,0.03])[0]
            del_dt = (exp_dt + timedelta(days=delay)).isoformat()
            dstatus = "Delivered"
        elif ostatus == "Shipped":
            del_dt  = None
            dstatus = "In Transit"
        elif ostatus == "Cancelled":
            del_dt  = None
            dstatus = "Returned"
        else:
            del_dt  = None
            dstatus = "In Transit"

        cur.execute("""
            INSERT INTO Shipments
              (shipment_id, order_id, shipped_date, expected_date, delivered_date,
               carrier, tracking_number, delivery_status, delay_days)
            VALUES (?,?,?,?,?,?,?,?,?)
        """, (sid, oid, ship_dt.isoformat(), exp_dt.isoformat(),
              del_dt, carrier, track, dstatus, delay))

    conn.commit()
    print(f"✅  Inserted {len(orders)} shipment records")

    # ── 6. Returns (~8% of delivered orders) ─────────────────
    cur.execute("""
        SELECT o.order_id, oi.product_id, oi.unit_price, oi.quantity
        FROM Orders o
        JOIN Order_Items oi ON o.order_id = oi.order_id
        WHERE o.order_status = 'Delivered'
    """)
    delivered_items = cur.fetchall()
    return_pool = random.sample(delivered_items,
                                k=int(len(delivered_items) * 0.08))

    for oid, pid, price, qty in return_pool:
        cur.execute("SELECT order_date FROM Orders WHERE order_id=?", (oid,))
        row = cur.fetchone()
        if not row:
            continue
        odt       = date.fromisoformat(row[0])
        ret_dt    = odt + timedelta(days=random.randint(3, 15))
        reason    = random.choice(RETURN_REASONS)
        refund    = round(price * qty, 2)
        rstatus   = random.choices(
            ["Processed","Pending","Rejected"], weights=[0.80,0.15,0.05])[0]
        cur.execute("""
            INSERT INTO Returns
              (order_id, product_id, return_date, return_reason, refund_amount, refund_status)
            VALUES (?,?,?,?,?,?)
        """, (oid, pid, ret_dt.isoformat(), reason, refund, rstatus))

    conn.commit()
    print(f"✅  Inserted ~{len(return_pool)} return records")

    # ── Final verification ────────────────────────────────────
    print("\n📊  ROW COUNTS:")
    for table in ["Customers","Suppliers","Products","Orders","Order_Items","Shipments","Returns"]:
        cur.execute(f"SELECT COUNT(*) FROM {table}")
        print(f"   {table:<15} {cur.fetchone()[0]:>6} rows")

    conn.close()
    print(f"\n🎉  Database saved to: {DB_PATH}")


if __name__ == "__main__":
    build_db()
