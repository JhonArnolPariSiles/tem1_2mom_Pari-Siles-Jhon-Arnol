USE superstore;

-- Preparación de la vista de auditoría
CREATE OR REPLACE VIEW auditoria_superstore AS
SELECT
    r.*,
    CAST(TRIM(row_id) AS INT) AS row_id_num,
    CAST(TRIM(sales) AS DECIMAL(18,4)) AS sales_num,
    CAST(TRIM(discount) AS DECIMAL(18,6)) AS discount_num,
    CAST(
        FROM_UNIXTIME(
            UNIX_TIMESTAMP(TRIM(order_date), 'M/d/yyyy')
        ) AS DATE
    ) AS fecha_pedido,
    CAST(
        FROM_UNIXTIME(
            UNIX_TIMESTAMP(TRIM(ship_date), 'M/d/yyyy')
        ) AS DATE
    ) AS fecha_envio,
    CASE
        WHEN order_date IS NULL OR TRIM(order_date) = '' THEN 1
        WHEN FROM_UNIXTIME(
            UNIX_TIMESTAMP(TRIM(order_date), 'M/d/yyyy'),
            'M/d/yyyy'
        ) = TRIM(order_date) THEN 0
        ELSE 1
    END AS pedido_invalido,
    CASE
        WHEN ship_date IS NULL OR TRIM(ship_date) = '' THEN 1
        WHEN FROM_UNIXTIME(
            UNIX_TIMESTAMP(TRIM(ship_date), 'M/d/yyyy'),
            'M/d/yyyy'
        ) = TRIM(ship_date) THEN 0
        ELSE 1
    END AS envio_invalido
FROM superstore_raw r;

-- 1. Cantidad total de registros
SELECT COUNT(*) AS total_registros
FROM auditoria_superstore;

-- 2. Identificadores de fila duplicados
SELECT
    COUNT(*) AS identificadores_duplicados,
    COALESCE(SUM(cantidad - 1), 0) AS filas_duplicadas_adicionales
FROM (
    SELECT row_id_num, COUNT(*) AS cantidad
    FROM auditoria_superstore
    WHERE row_id_num IS NOT NULL
    GROUP BY row_id_num
    HAVING COUNT(*) > 1
) d;

-- 3. Órdenes y clientes únicos
SELECT
    COUNT(DISTINCT CASE
        WHEN TRIM(order_id) <> '' THEN TRIM(order_id)
    END) AS ordenes_unicas,
    COUNT(DISTINCT CASE
        WHEN TRIM(customer_id) <> '' THEN TRIM(customer_id)
    END) AS clientes_unicos
FROM auditoria_superstore;

-- 4. Campos con valores NULL o vacíos
WITH campos AS (
    SELECT campo, valor
    FROM superstore_raw
    LATERAL VIEW STACK(
        21,
        'row_id', row_id,
        'order_id', order_id,
        'order_date', order_date,
        'ship_date', ship_date,
        'ship_mode', ship_mode,
        'customer_id', customer_id,
        'customer_name', customer_name,
        'segment', segment,
        'country', country,
        'city', city,
        'state', state,
        'postal_code', postal_code,
        'region', region,
        'product_id', product_id,
        'category', category,
        'sub_category', sub_category,
        'product_name', product_name,
        'sales', sales,
        'quantity', quantity,
        'discount', discount,
        'profit', profit
    ) s AS campo, valor
)
SELECT
    campo,
    SUM(CASE WHEN valor IS NULL THEN 1 ELSE 0 END) AS cantidad_null,
    SUM(CASE WHEN TRIM(valor) = '' THEN 1 ELSE 0 END) AS cantidad_vacios
FROM campos
GROUP BY campo
HAVING SUM(
    CASE WHEN valor IS NULL OR TRIM(valor) = '' THEN 1 ELSE 0 END
) > 0;

-- 5. Fechas inválidas o inconsistentes
SELECT
    row_id,
    order_id,
    order_date,
    ship_date,
    pedido_invalido,
    envio_invalido
FROM auditoria_superstore
WHERE pedido_invalido = 1
   OR envio_invalido = 1
   OR fecha_envio < fecha_pedido;

-- 6. Ventas iguales o inferiores a cero
SELECT
    row_id,
    order_id,
    product_name,
    sales_num
FROM auditoria_superstore
WHERE sales_num <= 0;

-- 7. Descuentos fuera del intervalo esperado
SELECT
    row_id,
    order_id,
    discount_num
FROM auditoria_superstore
WHERE discount_num < 0 OR discount_num > 1;

-- 8. Envíos anteriores al pedido
SELECT
    row_id,
    order_id,
    fecha_pedido,
    fecha_envio
FROM auditoria_superstore
WHERE pedido_invalido = 0
  AND envio_invalido = 0
  AND fecha_envio < fecha_pedido;