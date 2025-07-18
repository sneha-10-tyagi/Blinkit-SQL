# 🛒 BLINKIT E-commerce SQL Project

A full-fledged SQL case study analyzing grocery order operations for a Blinkit-style hyperlocal delivery system.

---

## 📌 Project Overview

1. **Real-world Case Study:**  
   A simulated analysis of Blinkit-style operations using a relational PostgreSQL database with four interconnected tables.

2. **Business-Focused Exploration:**  
   Identified operational inefficiencies, customer patterns, and product-level risks using advanced SQL queries.

3. **Data-Driven Decision Support:**  
   Delivered meaningful insights to optimize delivery timing, pricing strategy, and stock management.

---

## 📁 Dataset Overview

The dataset simulates a real-world e-commerce delivery system. It contains customer order details, product information, and delivery performance metrics — structured into four interrelated tables:

- `orders`
- `order_items`
- `delivery_performance`
- `products`

Each table captures a distinct aspect of the system and is linked via the `order_id` key. The data has been cleaned and normalized for relational analysis.

---

### 🧾 Table: `orders`

Each row in the `orders` table represents a unique customer order placed through the platform.

**Columns:**
- **order_id:** Unique identifier for each order (Primary Key)
- **customer_id:** Unique ID of the customer who placed the order
- **order_date:** Timestamp when the order was placed
- **promised_delivery_time:** Scheduled delivery time as promised at checkout
- **actual_delivery_time:** Actual time the order was delivered
- **delivery_status:** Final delivery status (e.g., *On Time*, *Delayed*)
- **order_total:** Total amount of the order in ₹ (including all items)
- **payment_method:** Payment type (e.g., *Cash*, *Card*, *UPI*)
- **delivery_partner_id:** ID of the delivery personnel or service provider
- **store_id:** ID of the store or warehouse that fulfilled the order

---

### 🧾 Table: `order_items`

This table breaks down each order into individual products. Each row represents one item in a specific order.

**Columns:**
- **order_id:** ID of the associated order (Foreign Key)
- **product_id:** Specific product variant (like size, brand, packaging)
- **quantity:** Number of units of the product in the order
- **unit_price:** Price per unit of the product (in ₹)

---

### 🧾 Table: `delivery_performance`

Captures actual delivery metrics for each order, including delays, distances, and issues during fulfillment.

**Columns:**
- **order_id:** ID of the order (Primary Key, and Foreign Key to `orders`)
- **delivery_partner_id:** ID of the delivery agent handling the order
- **promised_time:** Scheduled delivery time
- **actual_time:** Actual delivery completion time
- **delivery_time_minutes:** Time taken (in minutes); negative if early
- **distance_km:** Distance covered by the delivery in kilometers
- **delivery_status:** Actual delivery status (e.g., *On Time*, *Delayed*)
- **reasons_if_delayed:** Text field describing reasons for delay (e.g., *Traffic*, *Rain*, or left blank if on time)

---

### 🧾 Table: `products`

Contains metadata and inventory details for each product listed in the platform’s catalog. Each row represents a unique product SKU, including pricing, category, brand, and stock control metrics.

**Columns:**
- **product_id:** Unique identifier for each product (Primary Key)
- **product_name:** Name of the product (e.g., Onions, Potatoes)
- **category:** Category under which the product is listed (e.g., *Fruits & Vegetables*, *Dairy*, *Snacks*)
- **brand:** Brand or supplier associated with the product
- **price:** Selling price shown to customers (in ₹)
- **mrp:** Maximum Retail Price of the product (in ₹)
- **margin_percentage:** Percentage margin between price and MRP
- **shelf_life_days:** Shelf life of the product in days (used for perishability tracking)
- **min_stock_level:** Minimum number of units to keep in stock before triggering restock
- **max_stock_level:** Maximum allowed stock level for inventory control

---

## 🧪 Data Exploration

A detailed exploration was performed (see `exploration.sql`), covering:

- Order volume and date ranges
- Customer count and payment methods
- Order-item relationships and frequent products
- Delay patterns across delivery partners and times of day
- Data integrity checks: orphaned keys, negative values, nulls

---

## 🧹 Data Cleaning Status

**No explicit cleaning was needed.** Here’s why:

- All foreign key relationships were validated (no orphaned keys)
- No nulls or invalid values in critical columns
- Negative delivery times were explainable (early deliveries)
- Price mismatches between MRP and sale price represent real-world discounting logic

✔️ The dataset was clean and well-structured for SQL analysis.

---

## ⚠️ Known Data Limitations

1. **One order per store ID**  
   → Each `store_id` appears only once, preventing any store-level trend or consistency analysis.

2. **One delivery per delivery person**  
   → Each `delivery_partner_id` appears only once, preventing any delivery trend or order consistency analysis of the delivery partners.

3. **Mismatch between `order_total` and item-level total**  
   → The total order value does not always equal the sum of product prices from `order_items`.  
   Possible reasons include:
   - Discounts or service charges not reflected at the item level
   - Synthetic nature of dataset
   - Precomputed totals (similar to real-world checkout flows)

> ✅ Accounted for during analysis. For monetary insights, `orders.order_total` was prioritized.

---

## 📊 Business Insights (see `business_insights.sql`)

The project provides **advanced business analysis** using SQL constructs such as CTEs, DENSE_RANK, NTILE, CASE, and window functions.

---

## 📌 Highlighted Insight Example

> 🧠 **Observation:**  
> High-value orders are not consistently delivered faster than lower-value orders.

> 💼 **Business Insight:**  
> High-paying customers may not be receiving preferred delivery service. Prioritizing these users can improve satisfaction and retention.

---

## 📊 Tableau Dashboard

A visual layer was added on top of the SQL insights using Tableau.

📌 **View Dashboard:**  
🔗 [DASHBOARD – Logistics & Order Analysis (Tableau Public)](https://public.tableau.com/views/Book1_17527653100040/DASHBOARD-LogisticsOrderAnalysis?:language=en-GB&publish=yes)

The dashboard covers:

- Product revenue by stock capacity
- At-risk inventory detection
- High cost, low quantity order
- Top customer segments of both years
- High margin, low sales products
- Average delivery delay by time of the day

> 🧩 Charts are organized across 6 analytical views with filters by category, time, and orders.

---

## 📂 Files Included

| Filename              | Description                                      |
|-----------------------|--------------------------------------------------|
| `schema.sql`          | SQL code for table creation                      |
| `exploration.sql`     | Data exploration and validation queries          |
| `business_insights.sql` | Advanced queries for business analysis         |
| `blinkit_dashboard.twbx` | Tableau workbook file if exported             |

---

## 🛠️ Tools Used

- PostgreSQL (v17)
- pgAdmin
- Tableau Public

---

## 🧾 Author Note

This is the first complete project under my Data Analyst journey — proudly built from schema design to advanced querying and visualization.  
Any feedback or suggestions are welcome!

