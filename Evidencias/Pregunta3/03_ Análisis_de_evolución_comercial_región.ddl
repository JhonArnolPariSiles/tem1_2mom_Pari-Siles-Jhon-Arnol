0: jdbc:hive2://localhost:10000/default> WITH resumen_anual AS (
. . . . . . . . . . . . . . . . . . . .>     SELECT
. . . . . . . . . . . . . . . . . . . .>         region,
. . . . . . . . . . . . . . . . . . . .>         YEAR(order_date) AS anio,
. . . . . . . . . . . . . . . . . . . .>         SUM(sales) AS ventas_totales,
. . . . . . . . . . . . . . . . . . . .>         SUM(profit) AS ganancia_total
. . . . . . . . . . . . . . . . . . . .>     FROM superstore_analitica
. . . . . . . . . . . . . . . . . . . .>     WHERE order_date IS NOT NULL
. . . . . . . . . . . . . . . . . . . .>       AND region IS NOT NULL
. . . . . . . . . . . . . . . . . . . .>       AND TRIM(region) <> ''
. . . . . . . . . . . . . . . . . . . .>     GROUP BY region, YEAR(order_date)
. . . . . . . . . . . . . . . . . . . .> ),
. . . . . . . . . . . . . . . . . . . .> comparacion AS (
. . . . . . . . . . . . . . . . . . . .>     SELECT
. . . . . . . . . . . . . . . . . . . .>         *,
. . . . . . . . . . . . . . . . . . . .>         LAG(anio) OVER (
. . . . . . . . . . . . . . . . . . . .>             PARTITION BY region ORDER BY anio
. . . . . . . . . . . . . . . . . . . .>         ) AS anio_anterior,
. . . . . . . . . . . . . . . . . . . .>         LAG(ventas_totales) OVER (
. . . . . . . . . . . . . . . . . . . .>             PARTITION BY region ORDER BY anio
. . . . . . . . . . . . . . . . . . . .>         ) AS ventas_anio_anterior,
. . . . . . . . . . . . . . . . . . . .>         LAG(ganancia_total) OVER (
. . . . . . . . . . . . . . . . . . . .>             PARTITION BY region ORDER BY anio
. . . . . . . . . . . . . . . . . . . .>         ) AS ganancia_anio_anterior
. . . . . . . . . . . . . . . . . . . .>     FROM resumen_anual
. . . . . . . . . . . . . . . . . . . .> ),
. . . . . . . . . . . . . . . . . . . .> ranking AS (
. . . . . . . . . . . . . . . . . . . .>     SELECT
. . . . . . . . . . . . . . . . . . . .>         *,
. . . . . . . . . . . . . . . . . . . .>         DENSE_RANK() OVER (
. . . . . . . . . . . . . . . . . . . .>             PARTITION BY anio ORDER BY ganancia_total DESC
. . . . . . . . . . . . . . . . . . . .>         ) AS ranking_ganancia,
. . . . . . . . . . . . . . . . . . . .>         DENSE_RANK() OVER (
. . . . . . . . . . . . . . . . . . . .>             PARTITION BY anio ORDER BY ganancia_total ASC
. . . . . . . . . . . . . . . . . . . .>         ) AS ranking_peor
. . . . . . . . . . . . . . . . . . . .>     FROM comparacion
. . . . . . . . . . . . . . . . . . . .> )
. . . . . . . . . . . . . . . . . . . .> SELECT
. . . . . . . . . . . . . . . . . . . .>     anio,
. . . . . . . . . . . . . . . . . . . .>     region,
. . . . . . . . . . . . . . . . . . . .>     ROUND(ventas_totales, 2) AS ventas_totales,
. . . . . . . . . . . . . . . . . . . .>     ROUND(ganancia_total, 2) AS ganancia_total,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>     CASE
. . . . . . . . . . . . . . . . . . . .>         WHEN ventas_totales <> 0
. . . . . . . . . . . . . . . . . . . .>         THEN ROUND(
. . . . . . . . . . . . . . . . . . . .>             100.0 * ganancia_total / ventas_totales, 2
. . . . . . . . . . . . . . . . . . . .>         )
. . . . . . . . . . . . . . . . . . . .>     END AS margen_rentabilidad_pct,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>     CASE
. . . . . . . . . . . . . . . . . . . .>         WHEN anio_anterior = anio - 1
. . . . . . . . . . . . . . . . . . . .>          AND ventas_anio_anterior <> 0
. . . . . . . . . . . . . . . . . . . .>         THEN ROUND(
. . . . . . . . . . . . . . . . . . . .>             100.0 * (ventas_totales - ventas_anio_anterior)
. . . . . . . . . . . . . . . . . . . .>             / ABS(ventas_anio_anterior), 2
. . . . . . . . . . . . . . . . . . . .>         )
. . . . . . . . . . . . . . . . . . . .>     END AS variacion_ventas_pct,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>     CASE
. . . . . . . . . . . . . . . . . . . .>         WHEN anio_anterior = anio - 1
. . . . . . . . . . . . . . . . . . . .>          AND ganancia_anio_anterior <> 0
. . . . . . . . . . . . . . . . . . . .>         THEN ROUND(
. . . . . . . . . . . . . . . . . . . .>             100.0 * (ganancia_total - ganancia_anio_anterior)
. . . . . . . . . . . . . . . . . . . .>             / ABS(ganancia_anio_anterior), 2
. . . . . . . . . . . . . . . . . . . .>         )
. . . . . . . . . . . . . . . . . . . .>     END AS variacion_ganancia_pct,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>     ranking_ganancia,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>     CASE
. . . . . . . . . . . . . . . . . . . .>         WHEN ranking_ganancia = 1 AND ranking_peor = 1
. . . . . . . . . . . . . . . . . . . .>             THEN 'MISMA GANANCIA EN TODAS LAS REGIONES'
. . . . . . . . . . . . . . . . . . . .>         WHEN ranking_ganancia = 1 THEN 'MEJOR'
. . . . . . . . . . . . . . . . . . . .>         WHEN ranking_peor = 1 THEN 'PEOR'
. . . . . . . . . . . . . . . . . . . .>         ELSE 'INTERMEDIO'
. . . . . . . . . . . . . . . . . . . .>     END AS desempeno_anual
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .> FROM ranking
. . . . . . . . . . . . . . . . . . . .> ORDER BY anio, ranking_ganancia, region;
WARNING: Hive-on-MR is deprecated in Hive 2 and may not be available in the future versions. Consider using a different execution engine (i.e. spark, tez) or using Hive 1.X releases.
+-------+----------+-----------------+-----------------+--------------------------+-----------------------+-------------------------+-------------------+------------------+
| anio  |  region  | ventas_totales  | ganancia_total  | margen_rentabilidad_pct  | variacion_ventas_pct  | variacion_ganancia_pct  | ranking_ganancia  | desempeno_anual  |
+-------+----------+-----------------+-----------------+--------------------------+-----------------------+-------------------------+-------------------+------------------+
| 2014  | West     | 147883.03       | 20065.69        | 13.57                    | NULL                  | NULL                    | 1                 | MEJOR            |
| 2014  | East     | 128680.46       | 17059.61        | 13.26                    | NULL                  | NULL                    | 2                 | INTERMEDIO       |
| 2014  | South    | 103845.84       | 11879.12        | 11.44                    | NULL                  | NULL                    | 3                 | INTERMEDIO       |
| 2014  | Central  | 103838.16       | 539.55          | 0.52                     | NULL                  | NULL                    | 4                 | PEOR             |
| 2015  | East     | 156332.06       | 21091.01        | 13.49                    | 21.49                 | 23.63                   | 1                 | MEJOR            |
| 2015  | West     | 139966.25       | 20492.19        | 14.64                    | -5.35                 | 2.13                    | 2                 | INTERMEDIO       |
| 2015  | Central  | 102874.22       | 11716.80        | 11.39                    | -0.93                 | 2071.57                 | 3                 | INTERMEDIO       |
| 2015  | South    | 71359.98        | 8318.59         | 11.66                    | -31.28                | -29.97                  | 4                 | PEOR             |
| 2016  | West     | 187480.18       | 24051.61        | 12.83                    | 33.95                 | 17.37                   | 1                 | MEJOR            |
| 2016  | East     | 180685.82       | 20141.60        | 11.15                    | 15.58                 | -4.50                   | 2                 | INTERMEDIO       |
| 2016  | Central  | 147429.38       | 19899.16        | 13.50                    | 43.31                 | 69.83                   | 3                 | INTERMEDIO       |
| 2016  | South    | 93610.22        | 17702.81        | 18.91                    | 31.18                 | 112.81                  | 4                 | PEOR             |
| 2017  | West     | 250128.37       | 43808.96        | 17.51                    | 33.42                 | 82.15                   | 1                 | MEJOR            |
| 2017  | East     | 213082.90       | 33230.56        | 15.60                    | 17.93                 | 64.98                   | 2                 | INTERMEDIO       |
| 2017  | South    | 122905.86       | 8848.91         | 7.20                     | 31.30                 | -50.01                  | 3                 | INTERMEDIO       |
| 2017  | Central  | 147098.13       | 7550.84         | 5.13                     | -0.22                 | -62.05                  | 4                 | PEOR             |
+-------+----------+-----------------+-----------------+--------------------------+-----------------------+-------------------------+-------------------+------------------+
16 rows selected (4.838 seconds)
0: jdbc:hive2://localhost:10000/default> 