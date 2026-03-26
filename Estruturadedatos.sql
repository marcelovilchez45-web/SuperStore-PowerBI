
-- Fase 1 (Preparacion)

CREATE DATABASE IF NOT EXISTS bi_superstore;
USE bi_superstore;

DROP TABLE IF EXISTS stg_superstore_orders;

CREATE TABLE stg_superstore_orders (
    row_id INT AUTO_INCREMENT PRIMARY KEY, -- Clave subrogada para control de staging
    order_id VARCHAR(50) NOT NULL,
    order_date DATE NOT NULL,
    ship_date DATE,
    ship_mode VARCHAR(50),
    customer_name VARCHAR(150),
    segment VARCHAR(50),
    state VARCHAR(100),
    country VARCHAR(100),
    market VARCHAR(50),
    region VARCHAR(50),
    product_id VARCHAR(50) NOT NULL,
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(255),
    sales DECIMAL(15, 4),
    quantity INT,
    discount DECIMAL(5, 4),
    profit DECIMAL(15, 4),
    shipping_cost DECIMAL(15, 4),
    order_priority VARCHAR(50),
    order_year INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.6/Uploads/SuperStoreOrders - SuperStoreOrders.csv'
INTO TABLE stg_superstore_orders
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(
    order_id, 
    @v_order_date, 
    @v_ship_date, 
    ship_mode, 
    customer_name, 
    segment, 
    state, 
    country, 
    market, 
    region, 
    product_id, 
    category, 
    sub_category, 
    product_name, 
    @v_sales, 
    quantity, 
    @v_discount, 
    @v_profit, 
    @v_shipping_cost, 
    order_priority, 
    order_year
)
SET 
    order_date = STR_TO_DATE(@v_order_date, '%d/%m/%Y'),
    ship_date = STR_TO_DATE(@v_ship_date, '%d/%m/%Y'),
    sales = NULLIF(REPLACE(REPLACE(@v_sales, '$', ''), ',', ''), ''),
    discount = NULLIF(@v_discount, ''),
    profit = NULLIF(REPLACE(REPLACE(@v_profit, '$', ''), ',', ''), ''),
    shipping_cost = NULLIF(REPLACE(REPLACE(@v_shipping_cost, '$', ''), ',', ''), '');
    
    SET GLOBAL local_infile = 1;
   
-- Pruebas de Verificacion:
   
    SELECT COUNT(*) AS Total_Registros 
FROM stg_superstore_orders;
-- El resultado debe coincidir exactamente con (Filas de tu CSV - 1 del encabezado)

-- Verificacion de registros nulos

SELECT 
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS order_date_nulos,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS product_id_nulos,
    SUM(CASE WHEN sales IS NULL THEN 1 ELSE 0 END) AS sales_nulos
FROM stg_superstore_orders;

SELECT 
    order_id, 
    product_id, 
    COUNT(*) as Frecuencia
FROM stg_superstore_orders
GROUP BY 
    order_id, 
    product_id
HAVING COUNT(*) > 1
ORDER BY Frecuencia DESC;

SELECT 
    MIN(order_date) as Fecha_Mas_Antigua,
    MAX(order_date) as Fecha_Mas_Reciente
FROM stg_superstore_orders;





