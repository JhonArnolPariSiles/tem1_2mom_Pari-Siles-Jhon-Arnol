USE superstore;

WITH resumen_anual AS (
    SELECT
        region,
        YEAR(order_date) AS anio,
        SUM(sales) AS ventas_totales,
        SUM(profit) AS ganancia_total
    FROM superstore_analitica
    WHERE order_date IS NOT NULL
      AND region IS NOT NULL
      AND TRIM(region) <> ''
    GROUP BY region, YEAR(order_date)
),
comparacion AS (
    SELECT
        *,
        LAG(anio) OVER (
            PARTITION BY region ORDER BY anio
        ) AS anio_anterior,
        LAG(ventas_totales) OVER (
            PARTITION BY region ORDER BY anio
        ) AS ventas_anio_anterior,
        LAG(ganancia_total) OVER (
            PARTITION BY region ORDER BY anio
        ) AS ganancia_anio_anterior
    FROM resumen_anual
),
ranking AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY anio ORDER BY ganancia_total DESC
        ) AS ranking_ganancia,
        DENSE_RANK() OVER (
            PARTITION BY anio ORDER BY ganancia_total ASC
        ) AS ranking_peor
    FROM comparacion
)
SELECT
    anio,
    region,
    ROUND(ventas_totales, 2) AS ventas_totales,
    ROUND(ganancia_total, 2) AS ganancia_total,

    CASE
        WHEN ventas_totales <> 0
        THEN ROUND(
            100.0 * ganancia_total / ventas_totales, 2
        )
    END AS margen_rentabilidad_pct,

    CASE
        WHEN anio_anterior = anio - 1
         AND ventas_anio_anterior <> 0
        THEN ROUND(
            100.0 * (ventas_totales - ventas_anio_anterior)
            / ABS(ventas_anio_anterior), 2
        )
    END AS variacion_ventas_pct,

    CASE
        WHEN anio_anterior = anio - 1
         AND ganancia_anio_anterior <> 0
        THEN ROUND(
            100.0 * (ganancia_total - ganancia_anio_anterior)
            / ABS(ganancia_anio_anterior), 2
        )
    END AS variacion_ganancia_pct,

    ranking_ganancia,

    CASE
        WHEN ranking_ganancia = 1 AND ranking_peor = 1
            THEN 'MISMA GANANCIA EN TODAS LAS REGIONES'
        WHEN ranking_ganancia = 1 THEN 'MEJOR'
        WHEN ranking_peor = 1 THEN 'PEOR'
        ELSE 'INTERMEDIO'
    END AS desempeno_anual

FROM ranking
ORDER BY anio, ranking_ganancia, region;

