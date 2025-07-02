-- ============================================
-- Database: BlinkitOrder
-- Tables  : orders, order_items, delivery_performance, products
-- ============================================

-- -----------------------------------------------------
-- Table structure for `orders`
-- This is the main parent table. Other tables link to it via `order_id`.
-- -----------------------------------------------------

CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY,              
    customer_id BIGINT NOT NULL,                
    order_date TIMESTAMP NOT NULL,             
    promised_delivery_time TIMESTAMP NOT NULL,  
    actual_delivery_time TIMESTAMP NOT NULL,   
    delivery_status VARCHAR(50),               
    order_total NUMERIC(10, 2),                 
    payment_method VARCHAR(20),               
    delivery_partner_id BIGINT,               
    store_id INT                             
);


-- -----------------------------------------------------
-- Table structure for `order_items`
-- This is a child table of `orders`. Each row represents one product in an order.
-- The combination of `order_id` and `product_id` is unique per row.
-- -----------------------------------------------------


CREATE TABLE order_items (
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL,
    unit_price NUMERIC(10, 2),
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
);

-- ---------------------------------------------------------------
-- Table structure for `delivery_performance`
-- One-to-one relationship with `orders` (same order_id).
-- ---------------------------------------------------------------

CREATE TABLE delivery_performance (
    order_id BIGINT PRIMARY KEY,
    delivery_partner_id BIGINT,
    promised_time TIMESTAMP,
    actual_time TIMESTAMP,
    delivery_time_minutes NUMERIC(5, 1),
    distance_km NUMERIC(5, 2),
    delivery_status VARCHAR(50),
    reasons_if_delayed TEXT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
);

-- -----------------------------------------------------
-- Table structure for `products`
-- Can be linked to `order_items.product_id` using a foreign key.
-- -----------------------------------------------------

CREATE TABLE products (
    product_id BIGINT PRIMARY KEY,            
    product_name VARCHAR(100),                
    category VARCHAR(50),                    
    brand VARCHAR(100),                    
    price NUMERIC(10, 2),                     
    mrp NUMERIC(10, 2),                        
    margin_percentage NUMERIC(5, 2),           
    shelf_life_days INT,                      
    min_stock_level INT,                     
    max_stock_level INT                       
);
