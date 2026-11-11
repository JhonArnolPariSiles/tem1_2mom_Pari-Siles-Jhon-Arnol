0: jdbc:hive2://localhost:10000/default> WITH resumen AS (
. . . . . . . . . . . . . . . . . . . .>     SELECT
. . . . . . . . . . . . . . . . . . . .>         orden_rango,
. . . . . . . . . . . . . . . . . . . .>         rango_descuento,
. . . . . . . . . . . . . . . . . . . .>         'RESUMEN DEL RANGO' AS nivel,
. . . . . . . . . . . . . . . . . . . .>         'TODAS' AS categoria,
. . . . . . . . . . . . . . . . . . . .>         'TODAS' AS subcategoria,
. . . . . . . . . . . . . . . . . . . .>         COUNT(*) AS registros,
. . . . . . . . . . . . . . . . . . . .>         SUM(sales) AS ventas,
. . . . . . . . . . . . . . . . . . . .>         SUM(profit) AS ganancias,
. . . . . . . . . . . . . . . . . . . .>         SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END) AS registros_perdida,
. . . . . . . . . . . . . . . . . . . .>         SUM(CASE WHEN profit < 0 THEN -profit ELSE 0 END)
. . . . . . . . . . . . . . . . . . . .>             AS importe_perdidas,
. . . . . . . . . . . . . . . . . . . .>         AVG(discount) AS descuento_promedio
. . . . . . . . . . . . . . . . . . . .>     FROM descuentos_superstore
. . . . . . . . . . . . . . . . . . . .>     GROUP BY orden_rango, rango_descuento
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>     UNION ALL
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>     SELECT
. . . . . . . . . . . . . . . . . . . .>         orden_rango,
. . . . . . . . . . . . . . . . . . . .>         rango_descuento,
. . . . . . . . . . . . . . . . . . . .>         'CATEGORIA' AS nivel,
. . . . . . . . . . . . . . . . . . . .>         category AS categoria,
. . . . . . . . . . . . . . . . . . . .>         'TODAS' AS subcategoria,
. . . . . . . . . . . . . . . . . . . .>         COUNT(*) AS registros,
. . . . . . . . . . . . . . . . . . . .>         SUM(sales) AS ventas,
. . . . . . . . . . . . . . . . . . . .>         SUM(profit) AS ganancias,
. . . . . . . . . . . . . . . . . . . .>         SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END),
. . . . . . . . . . . . . . . . . . . .>         SUM(CASE WHEN profit < 0 THEN -profit ELSE 0 END),
. . . . . . . . . . . . . . . . . . . .>         AVG(discount)
. . . . . . . . . . . . . . . . . . . .>     FROM descuentos_superstore
. . . . . . . . . . . . . . . . . . . .>     GROUP BY orden_rango, rango_descuento, category
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>     UNION ALL
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>     SELECT
. . . . . . . . . . . . . . . . . . . .>         orden_rango,
. . . . . . . . . . . . . . . . . . . .>         rango_descuento,
. . . . . . . . . . . . . . . . . . . .>         'SUBCATEGORIA' AS nivel,
. . . . . . . . . . . . . . . . . . . .>         category AS categoria,
. . . . . . . . . . . . . . . . . . . .>         sub_category AS subcategoria,
. . . . . . . . . . . . . . . . . . . .>         COUNT(*) AS registros,
. . . . . . . . . . . . . . . . . . . .>         SUM(sales) AS ventas,
. . . . . . . . . . . . . . . . . . . .>         SUM(profit) AS ganancias,
. . . . . . . . . . . . . . . . . . . .>         SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END),
. . . . . . . . . . . . . . . . . . . .>         SUM(CASE WHEN profit < 0 THEN -profit ELSE 0 END),
. . . . . . . . . . . . . . . . . . . .>         AVG(discount)
. . . . . . . . . . . . . . . . . . . .>     FROM descuentos_superstore
. . . . . . . . . . . . . . . . . . . .>     GROUP BY orden_rango, rango_descuento, category, sub_category
. . . . . . . . . . . . . . . . . . . .> ),
. . . . . . . . . . . . . . . . . . . .> indicadores AS (
. . . . . . . . . . . . . . . . . . . .>     SELECT
. . . . . . . . . . . . . . . . . . . .>         *,
. . . . . . . . . . . . . . . . . . . .>         100.0 * registros_perdida / registros AS porcentaje_no_rentables
. . . . . . . . . . . . . . . . . . . .>     FROM resumen
. . . . . . . . . . . . . . . . . . . .> ),
. . . . . . . . . . . . . . . . . . . .> ranking AS (
. . . . . . . . . . . . . . . . . . . .>     SELECT
. . . . . . . . . . . . . . . . . . . .>         *,
. . . . . . . . . . . . . . . . . . . .>         DENSE_RANK() OVER (
. . . . . . . . . . . . . . . . . . . .>             PARTITION BY orden_rango, nivel
. . . . . . . . . . . . . . . . . . . .>             ORDER BY importe_perdidas DESC
. . . . . . . . . . . . . . . . . . . .>         ) AS ranking_afectacion
. . . . . . . . . . . . . . . . . . . .>     FROM indicadores
. . . . . . . . . . . . . . . . . . . .> )
. . . . . . . . . . . . . . . . . . . .> SELECT
. . . . . . . . . . . . . . . . . . . .>     orden_rango,
. . . . . . . . . . . . . . . . . . . .>     rango_descuento,
. . . . . . . . . . . . . . . . . . . .>     nivel,
. . . . . . . . . . . . . . . . . . . .>     categoria,
. . . . . . . . . . . . . . . . . . . .>     subcategoria,
. . . . . . . . . . . . . . . . . . . .>     registros,
. . . . . . . . . . . . . . . . . . . .>     ROUND(ventas, 2) AS ventas_totales,
. . . . . . . . . . . . . . . . . . . .>     ROUND(ganancias, 2) AS ganancia_total,
. . . . . . . . . . . . . . . . . . . .>     CASE
. . . . . . . . . . . . . . . . . . . .>         WHEN ventas <> 0
. . . . . . . . . . . . . . . . . . . .>         THEN ROUND(100.0 * ganancias / ventas, 2)
. . . . . . . . . . . . . . . . . . . .>     END AS margen_rentabilidad_pct,
. . . . . . . . . . . . . . . . . . . .>     registros_perdida,
. . . . . . . . . . . . . . . . . . . .>     ROUND(porcentaje_no_rentables, 2) AS operaciones_no_rentables_pct,
. . . . . . . . . . . . . . . . . . . .>     ROUND(100.0 * descuento_promedio, 2) AS descuento_promedio_pct,
. . . . . . . . . . . . . . . . . . . .>     ROUND(importe_perdidas, 2) AS importe_perdidas,
. . . . . . . . . . . . . . . . . . . .>     ranking_afectacion
. . . . . . . . . . . . . . . . . . . .> FROM ranking
. . . . . . . . . . . . . . . . . . . .> ORDER BY orden_rango, nivel, ranking_afectacion, categoria, subcategoria;
WARNING: Hive-on-MR is deprecated in Hive 2 and may not be available in the future versions. Consider using a different execution engine (i.e. spark, tez) or using Hive 1.X releases.
+--------------+------------------+--------------------+------------------+---------------+------------+-----------------+-----------------+--------------------------+--------------------+-------------------------------+-------------------------+-------------------+---------------------+
| orden_rango  | rango_descuento  |       nivel        |    categoria     | subcategoria  | registros  | ventas_totales  | ganancia_total  | margen_rentabilidad_pct  | registros_perdida  | operaciones_no_rentables_pct  | descuento_promedio_pct  | importe_perdidas  | ranking_afectacion  |
+--------------+------------------+--------------------+------------------+---------------+------------+-----------------+-----------------+--------------------------+--------------------+-------------------------------+-------------------------+-------------------+---------------------+
| 1            | Sin descuento    | CATEGORIA          | Furniture        | TODAS         | 836        | 256025.27       | 58133.08        | 22.71                    | 0                  | 0.00                          | 0.00                    | 0.00              | 1                   |
| 1            | Sin descuento    | CATEGORIA          | Office Supplies  | TODAS         | 3129       | 442150.00       | 130506.11       | 29.52                    | 0                  | 0.00                          | 0.00                    | 0.00              | 1                   |
| 1            | Sin descuento    | CATEGORIA          | Technology       | TODAS         | 833        | 389733.20       | 132348.42       | 33.96                    | 0                  | 0.00                          | 0.00                    | 0.00              | 1                   |
| 1            | Sin descuento    | RESUMEN DEL RANGO  | TODAS            | TODAS         | 4798       | 1087908.47      | 320987.60       | 29.51                    | 0                  | 0.00                          | 0.00                    | 0.00              | 1                   |
| 1            | Sin descuento    | SUBCATEGORIA       | Furniture        | Bookcases     | 60         | 31935.98        | 6075.71         | 19.02                    | 0                  | 0.00                          | 0.00                    | 0.00              | 1                   |
| 1            | Sin descuento    | SUBCATEGORIA       | Furniture        | Chairs        | 133        | 91060.73        | 21933.10        | 24.09                    | 0                  | 0.00                          | 0.00                    | 0.00              | 1                   |
| 1            | Sin descuento    | SUBCATEGORIA       | Furniture        | Furnishings   | 571        | 61449.80        | 16847.97        | 27.42                    | 0                  | 0.00                          | 0.00                    | 0.00              | 1                   |
| 1            | Sin descuento    | SUBCATEGORIA       | Furniture        | Tables        | 72         | 71578.76        | 13276.30        | 18.55                    | 0                  | 0.00                          | 0.00                    | 0.00              | 1                   |
| 1            | Sin descuento    | SUBCATEGORIA       | Office Supplies  | Appliances    | 271        | 78066.19        | 23183.74        | 29.70                    | 0                  | 0.00                          | 0.00                    | 0.00              | 1                   |
| 1            | Sin descuento    | SUBCATEGORIA       | Office Supplies  | Art           | 498        | 18014.64        | 5380.60         | 29.87                    | 0                  | 0.00                          | 0.00                    | 0.00              | 1                   |
| 1            | Sin descuento    | SUBCATEGORIA       | Office Supplies  | Binders       | 337        | 81829.48        | 39314.45        | 48.04                    | 0                  | 0.00                          | 0.00                    | 0.00              | 1                   |
| 1            | Sin descuento    | SUBCATEGORIA       | Office Supplies  | Envelopes     | 152        | 10606.45        | 4976.98         | 46.92                    | 0                  | 0.00                          | 0.00                    | 0.00              | 1                   |
| 1            | Sin descuento    | SUBCATEGORIA       | Office Supplies  | Fasteners     | 128        | 1822.84         | 652.21          | 35.78                    | 0                  | 0.00                          | 0.00                    | 0.00              | 1                   |
| 1            | Sin descuento    | SUBCATEGORIA       | Office Supplies  | Labels        | 239        | 9239.56         | 4422.10         | 47.86                    | 0                  | 0.00                          | 0.00                    | 0.00              | 1                   |
| 1            | Sin descuento    | SUBCATEGORIA       | Office Supplies  | Paper         | 857        | 53157.87        | 25329.47        | 47.65                    | 0                  | 0.00                          | 0.00                    | 0.00              | 1                   |
| 1            | Sin descuento    | SUBCATEGORIA       | Office Supplies  | Storage       | 530        | 157853.76       | 25528.17        | 16.17                    | 0                  | 0.00                          | 0.00                    | 0.00              | 1                   |
| 1            | Sin descuento    | SUBCATEGORIA       | Office Supplies  | Supplies      | 117        | 31559.21        | 1718.39         | 5.44                     | 0                  | 0.00                          | 0.00                    | 0.00              | 1                   |
| 1            | Sin descuento    | SUBCATEGORIA       | Technology       | Accessories   | 471        | 118370.31       | 35289.25        | 29.81                    | 0                  | 0.00                          | 0.00                    | 0.00              | 1                   |
| 1            | Sin descuento    | SUBCATEGORIA       | Technology       | Copiers       | 22         | 76449.18        | 35556.13        | 46.51                    | 0                  | 0.00                          | 0.00                    | 0.00              | 1                   |
| 1            | Sin descuento    | SUBCATEGORIA       | Technology       | Machines      | 29         | 71034.00        | 27137.82        | 38.20                    | 0                  | 0.00                          | 0.00                    | 0.00              | 1                   |
| 1            | Sin descuento    | SUBCATEGORIA       | Technology       | Phones        | 311        | 123879.71       | 34365.21        | 27.74                    | 0                  | 0.00                          | 0.00                    | 0.00              | 1                   |
| 2            | Descuento bajo   | CATEGORIA          | Office Supplies  | TODAS         | 2217       | 237373.89       | 39124.83        | 16.48                    | 206                | 9.29                          | 19.93                   | 9475.12           | 1                   |
| 2            | Descuento bajo   | CATEGORIA          | Furniture        | TODAS         | 743        | 290823.78       | 14795.95        | 5.09                     | 187                | 25.17                         | 18.63                   | 6395.45           | 2                   |
| 2            | Descuento bajo   | CATEGORIA          | Technology       | TODAS         | 843        | 318324.57       | 46864.69        | 14.72                    | 130                | 15.42                         | 19.98                   | 1745.47           | 3                   |
| 2            | Descuento bajo   | RESUMEN DEL RANGO  | TODAS            | TODAS         | 3803       | 846522.24       | 100785.47       | 11.91                    | 523                | 13.75                         | 19.68                   | 17616.04          | 1                   |
| 2            | Descuento bajo   | SUBCATEGORIA       | Office Supplies  | Storage       | 316        | 65989.85        | -4249.35        | -6.44                    | 161                | 50.95                         | 20.00                   | 6426.30           | 1                   |
| 2            | Descuento bajo   | SUBCATEGORIA       | Furniture        | Chairs        | 326        | 167382.87       | 11394.19        | 6.81                     | 87                 | 26.69                         | 17.67                   | 3143.72           | 2                   |
| 2            | Descuento bajo   | SUBCATEGORIA       | Office Supplies  | Supplies      | 73         | 15114.33        | -2907.49        | -19.24                   | 33                 | 45.21                         | 20.00                   | 3015.62           | 3                   |
| 2            | Descuento bajo   | SUBCATEGORIA       | Furniture        | Tables        | 71         | 45430.23        | -303.56         | -0.67                    | 31                 | 43.66                         | 20.00                   | 1651.02           | 4                   |
| 2            | Descuento bajo   | SUBCATEGORIA       | Furniture        | Bookcases     | 98         | 54400.02        | 1549.49         | 2.85                     | 40                 | 40.82                         | 17.35                   | 1054.44           | 5                   |
| 2            | Descuento bajo   | SUBCATEGORIA       | Technology       | Accessories   | 304        | 49010.01        | 6647.38         | 13.56                    | 91                 | 29.93                         | 20.00                   | 930.63            | 6                   |
| 2            | Descuento bajo   | SUBCATEGORIA       | Technology       | Phones        | 469        | 171789.99       | 16536.31        | 9.63                     | 39                 | 8.32                          | 20.00                   | 814.84            | 7                   |
| 2            | Descuento bajo   | SUBCATEGORIA       | Furniture        | Furnishings   | 248        | 23610.66        | 2155.83         | 9.13                     | 29                 | 11.69                         | 20.00                   | 546.26            | 8                   |
| 2            | Descuento bajo   | SUBCATEGORIA       | Office Supplies  | Fasteners     | 89         | 1201.44         | 297.31          | 24.75                    | 12                 | 13.48                         | 20.00                   | 33.20             | 9                   |
| 2            | Descuento bajo   | SUBCATEGORIA       | Office Supplies  | Appliances    | 128        | 26083.44        | 3583.91         | 13.74                    | 0                  | 0.00                          | 18.75                   | 0.00              | 10                  |
| 2            | Descuento bajo   | SUBCATEGORIA       | Office Supplies  | Art           | 298        | 9104.15         | 1147.19         | 12.60                    | 0                  | 0.00                          | 20.00                   | 0.00              | 10                  |
| 2            | Descuento bajo   | SUBCATEGORIA       | Office Supplies  | Binders       | 573        | 85442.64        | 29417.81        | 34.43                    | 0                  | 0.00                          | 20.00                   | 0.00              | 10                  |
| 2            | Descuento bajo   | SUBCATEGORIA       | Office Supplies  | Envelopes     | 102        | 5869.95         | 1987.19         | 33.85                    | 0                  | 0.00                          | 20.00                   | 0.00              | 10                  |
| 2            | Descuento bajo   | SUBCATEGORIA       | Office Supplies  | Labels        | 125        | 3246.75         | 1124.16         | 34.62                    | 0                  | 0.00                          | 20.00                   | 0.00              | 10                  |
| 2            | Descuento bajo   | SUBCATEGORIA       | Office Supplies  | Paper         | 513        | 25321.34        | 8724.10         | 34.45                    | 0                  | 0.00                          | 20.00                   | 0.00              | 10                  |
| 2            | Descuento bajo   | SUBCATEGORIA       | Technology       | Copiers       | 37         | 56159.05        | 17878.71        | 31.84                    | 0                  | 0.00                          | 20.00                   | 0.00              | 10                  |
| 2            | Descuento bajo   | SUBCATEGORIA       | Technology       | Machines      | 33         | 41365.52        | 5802.29         | 14.03                    | 0                  | 0.00                          | 19.39                   | 0.00              | 10                  |
| 3            | Descuento medio  | CATEGORIA          | Furniture        | TODAS         | 389        | 186046.66       | -44638.16       | -23.99                   | 374                | 96.14                         | 35.27                   | 44701.06          | 1                   |
| 3            | Descuento medio  | CATEGORIA          | Technology       | TODAS         | 148        | 112494.75       | -14178.84       | -12.60                   | 118                | 79.73                         | 40.47                   | 17255.13          | 2                   |
| 3            | Descuento medio  | RESUMEN DEL RANGO  | TODAS            | TODAS         | 537        | 298541.41       | -58817.00       | -19.70                   | 492                | 91.62                         | 36.70                   | 61956.19          | 1                   |
| 3            | Descuento medio  | SUBCATEGORIA       | Furniture        | Tables        | 176        | 89956.54        | -30698.22       | -34.13                   | 172                | 97.73                         | 39.29                   | 30761.12          | 1                   |
| 3            | Descuento medio  | SUBCATEGORIA       | Technology       | Machines      | 30         | 61237.60        | -9976.03        | -16.29                   | 21                 | 70.00                         | 42.33                   | 10539.35          | 2                   |
| 3            | Descuento medio  | SUBCATEGORIA       | Furniture        | Bookcases     | 55         | 26084.62        | -7202.82        | -27.61                   | 54                 | 98.18                         | 37.53                   | 7202.82           | 3                   |
| 3            | Descuento medio  | SUBCATEGORIA       | Furniture        | Chairs        | 158        | 70005.50        | -6737.12        | -9.62                    | 148                | 93.67                         | 30.00                   | 6737.12           | 4                   |
| 3            | Descuento medio  | SUBCATEGORIA       | Technology       | Phones        | 109        | 34337.35        | -6385.79        | -18.60                   | 97                 | 88.99                         | 40.00                   | 6715.78           | 5                   |
| 3            | Descuento medio  | SUBCATEGORIA       | Technology       | Copiers       | 9          | 16919.80        | 2182.98         | 12.90                    | 0                  | 0.00                          | 40.00                   | 0.00              | 6                   |
| 4            | Descuento alto   | CATEGORIA          | Office Supplies  | TODAS         | 680        | 39523.15        | -47140.14       | -119.27                  | 680                | 100.00                        | 74.41                   | 47140.14          | 1                   |
| 4            | Descuento alto   | CATEGORIA          | Technology       | TODAS         | 23         | 15601.51        | -19579.32       | -125.50                  | 23                 | 100.00                        | 70.00                   | 19579.32          | 2                   |
| 4            | Descuento alto   | CATEGORIA          | Furniture        | TODAS         | 153        | 9104.08         | -9839.59        | -108.08                  | 153                | 100.00                        | 60.98                   | 9839.59           | 3                   |
| 4            | Descuento alto   | RESUMEN DEL RANGO  | TODAS            | TODAS         | 856        | 64228.74        | -76559.05       | -119.20                  | 856                | 100.00                        | 71.89                   | 76559.05          | 1                   |
| 4            | Descuento alto   | SUBCATEGORIA       | Office Supplies  | Binders       | 613        | 36140.61        | -38510.50       | -106.56                  | 613                | 100.00                        | 73.80                   | 38510.50          | 1                   |
| 4            | Descuento alto   | SUBCATEGORIA       | Technology       | Machines      | 23         | 15601.51        | -19579.32       | -125.50                  | 23                 | 100.00                        | 70.00                   | 19579.32          | 2                   |
| 4            | Descuento alto   | SUBCATEGORIA       | Office Supplies  | Appliances    | 67         | 3382.53         | -8629.64        | -255.12                  | 67                 | 100.00                        | 80.00                   | 8629.64           | 3                   |
| 4            | Descuento alto   | SUBCATEGORIA       | Furniture        | Furnishings   | 138        | 6644.70         | -5944.66        | -89.46                   | 138                | 100.00                        | 60.00                   | 5944.66           | 4                   |
| 4            | Descuento alto   | SUBCATEGORIA       | Furniture        | Bookcases     | 15         | 2459.38         | -3894.94        | -158.37                  | 15                 | 100.00                        | 70.00                   | 3894.94           | 5                   |
+--------------+------------------+--------------------+------------------+---------------+------------+-----------------+-----------------+--------------------------+--------------------+-------------------------------+-------------------------+-------------------+---------------------+
60 rows selected (7.153 seconds)
0: jdbc:hive2://localhost:10000/default> 