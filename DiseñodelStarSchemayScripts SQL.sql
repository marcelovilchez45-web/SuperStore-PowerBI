
-- Diseño del Star Schema y Scripts SQL

-- 2. Tablas de Dimensiones

CREATE TABLE dim_products (
    product_key INT AUTO_INCREMENT PRIMARY KEY,
    product_id VARCHAR(50),
    product_name VARCHAR(255),
    category VARCHAR(100),
    sub_category VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE dim_customers (
    customer_key INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(150),
    segment VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE dim_locations (
    location_key INT AUTO_INCREMENT PRIMARY KEY,
    country VARCHAR(100),
    state VARCHAR(100),
    market VARCHAR(50),
    region VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE dim_shipping (
    shipping_key INT AUTO_INCREMENT PRIMARY KEY,
    ship_mode VARCHAR(50),
    order_priority VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Tabla de Hechos
CREATE TABLE fact_sales (
    sales_key INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(50),
    order_date DATE,
    product_key INT,
    customer_key INT,
    location_key INT,
    shipping_key INT,
    sales DECIMAL(15,4),
    quantity INT,
    discount DECIMAL(15,4),
    profit DECIMAL(15,4),
    shipping_cost DECIMAL(15,4),
    FOREIGN KEY (product_key) REFERENCES dim_products(product_key),
    FOREIGN KEY (customer_key) REFERENCES dim_customers(customer_key),
    FOREIGN KEY (location_key) REFERENCES dim_locations(location_key),
    FOREIGN KEY (shipping_key) REFERENCES dim_shipping(shipping_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Pobrar las tablas ejecutas

-- Poblar Productos
INSERT INTO dim_products (product_id, product_name, category, sub_category)
SELECT DISTINCT product_id, product_name, category, sub_category 
FROM stg_superstore_orders;

-- Poblar Clientes
INSERT INTO dim_customers (customer_name, segment)
SELECT DISTINCT customer_name, segment 
FROM stg_superstore_orders;

-- Poblar Ubicaciones
INSERT INTO dim_locations (country, state, market, region)
SELECT DISTINCT country, state, market, region 
FROM stg_superstore_orders;

-- Poblar Envío
INSERT INTO dim_shipping (ship_mode, order_priority)
SELECT DISTINCT ship_mode, order_priority 
FROM stg_superstore_orders;

-- Pobrar la tabla de hechos

INSERT INTO fact_sales (
    order_id, order_date, product_key, customer_key, 
    location_key, shipping_key, sales, quantity, 
    discount, profit, shipping_cost
)
SELECT 
    s.order_id,
    s.order_date,
    p.product_key,
    c.customer_key,
    l.location_key,
    sh.shipping_key,
    s.sales,
    s.quantity,
    s.discount,
    s.profit,
    s.shipping_cost
FROM stg_superstore_orders s
JOIN dim_products p ON s.product_id = p.product_id AND s.product_name = p.product_name
JOIN dim_customers c ON s.customer_name = c.customer_name AND s.segment = c.segment
JOIN dim_locations l ON s.country = l.country AND s.state = l.state AND s.market = l.market AND s.region = l.region
JOIN dim_shipping sh ON s.ship_mode = sh.ship_mode AND s.order_priority = sh.order_priority;


-- Verificacion 

-- Si el resultado es mayor a 0, hubo filas en staging que no entraron a la Fact Table
SELECT 
    (SELECT COUNT(*) FROM stg_superstore_orders) AS Registros_Staging,
    (SELECT COUNT(*) FROM fact_sales) AS Registros_Fact;
    
    
