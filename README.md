# 🛒 BLINKIT E-commerce SQL Data Analyst Project

A full-fledged SQL case study analyzing grocery order operations for a Blinkit-style hyperlocal delivery system.

---

## 📌 Project Overview

1. **Real-world Case Study:**  
   A simulated analysis of Blinkit-style operations using a relational PostgreSQL database with four interconnected tables.

2. **Business-Focused Exploration:**  
   Identified operational inefficiencies, customer patterns, and product-level risks using advanced SQL queries.

3. **Data-Driven Decision Support:**  
   Delivered meaningful insights to optimize delivery timing, pricing strategy, and stock management.

4. **Portfolio-Ready Skills:**  
   Demonstrates expertise in `JOINs`, `CTEs`, `DENSE_RANK()`, `NTILE()`, `CASE WHEN`, and writing real-world business logic in SQL.

---

## 📁 Dataset Overview

The dataset simulates a real-world e-commerce delivery system similar to Blinkit or Zepto. It contains customer order details, itemized product information, and delivery performance metrics — structured into three interrelated tables:

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
- **product_id:** specific product variant (like size, brand, packaging)
- **quantity:** Number of units of the product in the order
- **unit_price:** Price per unit of the product (in ₹)

> ℹ️ Composite Primary Key: (`order_id`, `product_id`) ensures uniqueness of each line item per order.

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

**No explicit cleaning was needed**. Here’s why:

- All foreign key relationships were validated (no orphans)
- No nulls or invalid values in critical columns
- Negative delivery times were rare but explainable (early deliveries)
- Price and margin inconsistencies were business-valid (e.g., discounts)

✔️ The data was well-structured and analysis-ready out of the box.

---

## ⚠️ Known Data Limitations

1. **One order per store ID**  
   → Each `store_id` appears only once in the dataset, making it unsuitable for store-level trend or consistency analysis.

2. **Mismatch between `order_total` and item-level computed total**  
   → The `orders.order_total` field often doesn’t match the sum of `quantity * unit_price` from `order_items`.  
   Likely due to:
   - Precomputed totals (at checkout)
   - Discounts or charges not captured at item level
   - Partial or synthetic dataset

> ✅ This has been accounted for in analysis — any insights depending on true order value rely directly on `orders.order_total`.

---

## 📊 Business Insights (see `business_insights.sql`)

This project goes beyond exploration to uncover **data-backed insights** across operations, customer behavior, and inventory management:

### 🧮 Inventory + Product-Level

- **Which products generate the highest revenue per stock capacity?**
- **High margin, low-selling products** → Flag pricing inefficiencies
- **Short shelf-life + overstocked + slow-selling products** → At-risk inventory detection (📦⚠️)

### 🚚 Delivery Operations

- **Most consistent delivery partners** (lowest standard deviation)
- **Time of day with highest delivery delays**
- **Stress score for delivery partners**, categorized using DENSE_RANK + NTILE
- **Low-efficiency deliveries** → Long distances for low-value orders

### 💸 Customer Behavior

- **Top 10% of customers by spend** using NTILE (deciles)
- **Are high-value orders delivered faster?**  

## 💡 Highlighted Insight Example

> 🧠 **Observation:**  
> There is no clear correlation between higher order value and faster delivery.

> 💼 **Business Insight:**  
> High-value customers may not be receiving prioritized service. Optimizing delivery for these users could improve loyalty and satisfaction.

---

## 📂 Files Included

- `schema.sql` — Table creation (already included earlier)
- `exploration.sql` — Initial exploration and validation queries
- `business_insights.sql` — Deeper analytical queries with CTEs, window functions, and categorization logic

---

## 📌 Tools Used

- PostgreSQL (v17)
- pgAdmin for database and data import
- Excel/CSV preprocessing
- Tableau (planned for dashboard - coming next)

---
