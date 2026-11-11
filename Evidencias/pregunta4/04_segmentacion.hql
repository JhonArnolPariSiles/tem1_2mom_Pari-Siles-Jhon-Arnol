USE superstore;

WITH clientes AS (
    SELECT
        TRIM(customer_id) AS customer_id,
        MAX(customer_name) AS customer_name,
        MAX(order_date) AS ultima_compra,
        COUNT(DISTINCT order_id) AS frecuencia,
        SUM(sales) AS importe_total
    FROM superstore_analitica
    WHERE customer_id IS NOT NULL
      AND TRIM(customer_id) <> ''
      AND order_id IS NOT NULL
      AND TRIM(order_id) <> ''
      AND order_date IS NOT NULL
      AND sales > 0
    GROUP BY TRIM(customer_id)
),
referencia AS (
    SELECT MAX(order_date) AS fecha_referencia
    FROM superstore_analitica
),
combinados AS (
    SELECT
        customer_id,
        customer_name,
        ultima_compra,
        frecuencia,
        importe_total,
        CAST(NULL AS DATE) AS referencia_global
    FROM clientes

    UNION ALL

    SELECT
        CAST(NULL AS STRING),
        CAST(NULL AS STRING),
        CAST(NULL AS DATE),
        CAST(NULL AS BIGINT),
        CAST(NULL AS DECIMAL(28,4)),
        fecha_referencia
    FROM referencia
),
con_referencia AS (
    SELECT
        *,
        MAX(referencia_global) OVER () AS fecha_referencia
    FROM combinados
),
metricas AS (
    SELECT
        customer_id,
        customer_name,
        ultima_compra,
        frecuencia,
        importe_total,
        fecha_referencia,
        DATEDIFF(fecha_referencia, ultima_compra) AS recencia
    FROM con_referencia
    WHERE customer_id IS NOT NULL
),
puntuaciones AS (
    SELECT
        *,
        NTILE(5) OVER (
            ORDER BY recencia DESC, customer_id
        ) AS r_score,
        NTILE(5) OVER (
            ORDER BY frecuencia ASC, customer_id
        ) AS f_score,
        NTILE(5) OVER (
            ORDER BY importe_total ASC, customer_id
        ) AS m_score
    FROM metricas
)
SELECT
    customer_id,
    customer_name,
    fecha_referencia,
    ultima_compra,
    recencia AS recency_dias,
    frecuencia AS frequency_ordenes,
    ROUND(importe_total, 2) AS monetary_ventas,
    r_score,
    f_score,
    m_score,
    CONCAT(
        CAST(r_score AS STRING),
        CAST(f_score AS STRING),
        CAST(m_score AS STRING)
    ) AS codigo_rfm,
    r_score + f_score + m_score AS puntuacion_total,
    CASE
        WHEN r_score <= 2
         AND (f_score >= 4 OR m_score >= 4)
            THEN 'EN RIESGO - ANTES VALIOSO'
        WHEN r_score <= 2
            THEN 'EN RIESGO DE ABANDONO'
        WHEN r_score >= 4
         AND f_score >= 4
         AND m_score >= 4
            THEN 'ALTO VALOR'
        WHEN f_score >= 4
            THEN 'RECURRENTE'
        WHEN r_score >= 4 AND f_score <= 2
            THEN 'RECIENTE - BAJA FRECUENCIA'
        ELSE 'CLIENTE EN DESARROLLO'
    END AS segmento
FROM puntuaciones
ORDER BY puntuacion_total DESC, monetary_ventas DESC;
