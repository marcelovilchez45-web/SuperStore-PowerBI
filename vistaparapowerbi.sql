

-- Vista Granular Operativa (El "Cuerpo" del Modelo)

CREATE OR REPLACE VIEW vw_fact_ventas_detalle AS
SELECT 
    f.order_id,
    f.order_date,
    f.location_key, -- ESTE ES EL CONECTOR QUE FALTABA
    c.customer_name,
    c.segment,
    p.product_name,
    p.category,
    p.sub_category,
    l.country,
    l.market,
    sh.ship_mode,
    sh.order_priority,
    f.sales,
    f.quantity,
    f.discount,
    f.profit,
    f.shipping_cost
FROM fact_sales f
JOIN dim_products p ON f.product_key = p.product_key
JOIN dim_customers c ON f.customer_key = c.customer_key
JOIN dim_locations l ON f.location_key = l.location_key
JOIN dim_shipping sh ON f.shipping_key = sh.shipping_key;

-- Vista de Segmentación de Clientes (Frecuencia y Volumen)

CREATE OR REPLACE VIEW vw_analisis_clientes AS
SELECT 
    c.customer_name,
    c.segment,
    COUNT(f.sales_key) AS numero_compras,
    SUM(f.sales) AS volumen_ventas_historico,
    SUM(f.profit) AS rentabilidad_cliente
FROM fact_sales f
JOIN dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.customer_name, c.segment;

CREATE OR REPLACE VIEW vw_dimension_calendario AS
SELECT DISTINCT
    order_date AS fecha_id,
    YEAR(order_date) AS anio,
    MONTH(order_date) AS mes_numero,
    MONTHNAME(order_date) AS mes_nombre,
    QUARTER(order_date) AS trimestre,
    WEEK(order_date) AS semana_anio,
    DAYOFWEEK(order_date) AS dia_semana_numero,
    CASE WHEN DAYOFWEEK(order_date) IN (1, 7) THEN 'Fin de Semana' ELSE 'Día Laboral' END AS tipo_dia
FROM fact_sales;

-- Validaciones

-- El conteo de la vista granular debe ser igual al de la Fact Table
SELECT 
    (SELECT COUNT(*) FROM fact_sales) AS total_fact,
    (SELECT COUNT(*) FROM vw_fact_ventas_detalle) AS total_vista;
    
-- Si este query devuelve algo, hay un JOIN mal hecho que está filtrando datos
SELECT 'Ventas Perdidas' as Error, (SUM(f.sales) - (SELECT SUM(sales) FROM vw_fact_ventas_detalle)) as Diferencia
FROM fact_sales f; 

SELECT country, COUNT(*) as registros
FROM vw_performance_mercado
GROUP BY country
HAVING COUNT(*) > 1;





   