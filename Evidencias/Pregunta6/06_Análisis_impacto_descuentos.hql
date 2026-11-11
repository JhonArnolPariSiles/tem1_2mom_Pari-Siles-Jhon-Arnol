WITH resumen AS (
    SELECT
        orden_rango,
        rango_descuento,
        'RESUMEN DEL RANGO' AS nivel,
        'TODAS' AS categoria,
        'TODAS' AS subcategoria,
        COUNT(*) AS registros,
        SUM(sales) AS ventas,
        SUM(profit) AS ganancias,
        SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END) AS registros_perdida,
        SUM(CASE WHEN profit < 0 THEN -profit ELSE 0 END)
            AS importe_perdidas,
        AVG(discount) AS descuento_promedio
    FROM descuentos_superstore
    GROUP BY orden_rango, rango_descuento

    UNION ALL

    SELECT
        orden_rango,
        rango_descuento,
        'CATEGORIA' AS nivel,
        category AS categoria,
        'TODAS' AS subcategoria,
        COUNT(*) AS registros,
        SUM(sales) AS ventas,
        SUM(profit) AS ganancias,
        SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END),
        SUM(CASE WHEN profit < 0 THEN -profit ELSE 0 END),
        AVG(discount)
    FROM descuentos_superstore
    GROUP BY orden_rango, rango_descuento, category

    UNION ALL

    SELECT
        orden_rango,
        rango_descuento,
        'SUBCATEGORIA' AS nivel,
        category AS categoria,
        sub_category AS subcategoria,
        COUNT(*) AS registros,
        SUM(sales) AS ventas,
        SUM(profit) AS ganancias,
        SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END),
        SUM(CASE WHEN profit < 0 THEN -profit ELSE 0 END),
        AVG(discount)
    FROM descuentos_superstore
    GROUP BY orden_rango, rango_descuento, category, sub_category
),
indicadores AS (
    SELECT
        *,
        100.0 * registros_perdida / registros AS porcentaje_no_rentables
    FROM resumen
),
ranking AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY orden_rango, nivel
            ORDER BY importe_perdidas DESC
        ) AS ranking_afectacion
    FROM indicadores
)
SELECT
    orden_rango,
    rango_descuento,
    nivel,
    categoria,
    subcategoria,
    registros,
    ROUND(ventas, 2) AS ventas_totales,
    ROUND(ganancias, 2) AS ganancia_total,
    CASE
        WHEN ventas <> 0
        THEN ROUND(100.0 * ganancias / ventas, 2)
    END AS margen_rentabilidad_pct,
    registros_perdida,
    ROUND(porcentaje_no_rentables, 2) AS operaciones_no_rentables_pct,
    ROUND(100.0 * descuento_promedio, 2) AS descuento_promedio_pct,
    ROUND(importe_perdidas, 2) AS importe_perdidas,
    ranking_afectacion
FROM ranking
ORDER BY orden_rango, nivel, ranking_afectacion, categoria, subcategoria;
