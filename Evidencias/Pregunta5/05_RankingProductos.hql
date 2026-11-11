USE superstore;

WITH productos AS (
    SELECT
        category,
        product_id,
        MAX(product_name) AS product_name,
        SUM(quantity) AS unidades_vendidas,
        SUM(sales) AS ventas_totales,
        SUM(profit) AS ganancia_total,
        CASE
            WHEN SUM(sales) <> 0
            THEN 100.0 * SUM(profit) / SUM(sales)
        END AS margen_pct
    FROM superstore_analitica
    WHERE product_id IS NOT NULL
      AND TRIM(product_id) <> ''
    GROUP BY category, product_id
),
posiciones AS (
    SELECT
        *,
        RANK() OVER (
            PARTITION BY category
            ORDER BY ganancia_total DESC
        ) AS posicion_categoria,

        DENSE_RANK() OVER (
            PARTITION BY category
            ORDER BY ganancia_total DESC
        ) AS nivel_ganancia_categoria,

        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY ganancia_total DESC, product_id
        ) AS orden_top_categoria,

        ROW_NUMBER() OVER (
            ORDER BY unidades_vendidas DESC, product_id, category
        ) AS posicion_volumen,

        ROW_NUMBER() OVER (
            ORDER BY
                CASE WHEN margen_pct IS NULL THEN 1 ELSE 0 END,
                margen_pct ASC,
                product_id,
                category
        ) AS posicion_menor_margen,

        SUM(ganancia_total) OVER (
            PARTITION BY category
            ORDER BY ganancia_total DESC, product_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS ganancia_acumulada_categoria
    FROM productos
)
SELECT
    category,
    product_id,
    product_name,
    unidades_vendidas,
    ROUND(ventas_totales, 2) AS ventas_totales,
    ROUND(ganancia_total, 2) AS ganancia_total,
    ROUND(margen_pct, 2) AS margen_ganancia_pct,
    posicion_categoria,
    nivel_ganancia_categoria,
    ROUND(ganancia_acumulada_categoria, 2)
        AS ganancia_acumulada_categoria,

    CASE WHEN orden_top_categoria <= 5
        THEN 'SI' ELSE 'NO'
    END AS top5_ganancia_categoria,

    posicion_volumen,

    CASE WHEN posicion_volumen <= 5
        THEN 'SI' ELSE 'NO'
    END AS top5_unidades,

    posicion_menor_margen,

    CASE WHEN posicion_menor_margen <= 5
              AND margen_pct IS NOT NULL
        THEN 'SI' ELSE 'NO'
    END AS top5_menor_rentabilidad

FROM posiciones
WHERE orden_top_categoria <= 5
   OR posicion_volumen <= 5
   OR (posicion_menor_margen <= 5 AND margen_pct IS NOT NULL)
ORDER BY category, posicion_categoria, product_id;
