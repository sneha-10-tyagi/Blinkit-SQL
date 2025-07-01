# 🛒 BLINKIT E-commerce SQL Data Analyst Portfolio Project

## 📌 Project Overview

The goal is to simulate how actual data analysts in the e-commerce or retail industries work behind the scenes to use SQL to:

✅ Set up a messy, real-world e-commerce inventory **database**

✅ Perform **Exploratory Data Analysis (EDA)** to explore product categories, availability, and pricing inconsistencies

✅ Implement **Data Cleaning** to handle null values, remove invalid entries, and convert pricing from paise to rupees

✅ Write **business-driven SQL queries** to derive insights around **pricing, inventory, stock availability, revenue** and more

## 📁 Dataset Overview

The dataset simulates a real-world e-commerce delivery system similar to Blinkit or Zepto. It contains customer order details, itemized product information, and delivery performance metrics — structured into three interrelated tables:

- `orders`
- `order_items`
- `delivery_performance`

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
