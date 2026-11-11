USE superstore;

WITH mensual AS (
    SELECT
        YEAR(order_date) AS anio,
        MONTH(order_date) AS mes,
        YEAR(order_date) * 12 + MONTH(order_date) AS periodo,
        SUM(sales) AS ventas,
        SUM(profit) AS ganancias
    FROM superstore_analitica
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(order_date), MONTH(order_date)
),
ventanas AS (
    SELECT
        *,
        LAG(periodo, 1) OVER (ORDER BY periodo) AS periodo_previo,
        LAG(ventas, 1) OVER (ORDER BY periodo) AS ventas_mes_anterior,
        LAG(ganancias, 1) OVER (ORDER BY periodo)
            AS ganancias_mes_anterior,

        AVG(ventas) OVER (
            ORDER BY periodo
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS promedio_ventas_3m,

        AVG(ganancias) OVER (
            ORDER BY periodo
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS promedio_ganancias_3m,

        COUNT(*) OVER (
            ORDER BY periodo
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS meses_ventana,

        LAG(periodo, 2) OVER (ORDER BY periodo) AS periodo_hace_dos,

        ROW_NUMBER() OVER (
            ORDER BY ventas DESC, periodo
        ) AS ranking_mayor_venta,

        ROW_NUMBER() OVER (
            ORDER BY ventas ASC, periodo
        ) AS ranking_menor_venta
    FROM mensual
),
comparacion AS (
    SELECT
        a.*,
        b.ventas AS ventas_mismo_mes_anterior,
        b.ganancias AS ganancias_mismo_mes_anterior
    FROM ventanas a
    LEFT JOIN mensual b
        ON a.mes = b.mes
       AND a.anio = b.anio + 1
)
SELECT
    anio,
    mes,
    ROUND(ventas, 2) AS ventas_mensuales,
    ROUND(ganancias, 2) AS ganancias_mensuales,

    CASE
        WHEN periodo_previo = periodo - 1
         AND ventas_mes_anterior <> 0
        THEN ROUND(
            100.0 * (ventas - ventas_mes_anterior)
            / ABS(ventas_mes_anterior), 2
        )
    END AS variacion_ventas_mensual_pct,

    CASE
        WHEN periodo_previo = periodo - 1
         AND ganancias_mes_anterior <> 0
        THEN ROUND(
            100.0 * (ganancias - ganancias_mes_anterior)
            / ABS(ganancias_mes_anterior), 2
        )
    END AS variacion_ganancias_mensual_pct,

    ROUND(ventas_mismo_mes_anterior, 2)
        AS ventas_mismo_mes_anio_anterior,

    ROUND(ganancias_mismo_mes_anterior, 2)
        AS ganancias_mismo_mes_anio_anterior,

    CASE
        WHEN ventas_mismo_mes_anterior <> 0
        THEN ROUND(
            100.0 * (ventas - ventas_mismo_mes_anterior)
            / ABS(ventas_mismo_mes_anterior), 2
        )
    END AS variacion_ventas_interanual_pct,

    CASE
        WHEN ganancias_mismo_mes_anterior <> 0
        THEN ROUND(
            100.0 * (ganancias - ganancias_mismo_mes_anterior)
            / ABS(ganancias_mismo_mes_anterior), 2
        )
    END AS variacion_ganancias_interanual_pct,

    CASE
        WHEN meses_ventana = 3
         AND periodo_hace_dos = periodo - 2
        THEN ROUND(promedio_ventas_3m, 2)
    END AS promedio_movil_ventas_3m,

    CASE
        WHEN meses_ventana = 3
         AND periodo_hace_dos = periodo - 2
        THEN ROUND(promedio_ganancias_3m, 2)
    END AS promedio_movil_ganancias_3m,

    ranking_mayor_venta,
    ranking_menor_venta,

    CASE
        WHEN ranking_mayor_venta <= 3 THEN 'TOP 3 MAYOR VENTA'
        WHEN ranking_menor_venta <= 3 THEN 'TOP 3 MENOR VENTA'
        ELSE 'INTERMEDIO'
    END AS clasificacion_mes

FROM comparacion
ORDER BY anio, mes;
