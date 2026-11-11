0: jdbc:hive2://localhost:10000/default> WITH mensual AS (
. . . . . . . . . . . . . . . . . . . .>     SELECT
. . . . . . . . . . . . . . . . . . . .>         YEAR(order_date) AS anio,
. . . . . . . . . . . . . . . . . . . .>         MONTH(order_date) AS mes,
. . . . . . . . . . . . . . . . . . . .>         YEAR(order_date) * 12 + MONTH(order_date) AS periodo,
. . . . . . . . . . . . . . . . . . . .>         SUM(sales) AS ventas,
. . . . . . . . . . . . . . . . . . . .>         SUM(profit) AS ganancias
. . . . . . . . . . . . . . . . . . . .>     FROM superstore_analitica
. . . . . . . . . . . . . . . . . . . .>     WHERE order_date IS NOT NULL
. . . . . . . . . . . . . . . . . . . .>     GROUP BY YEAR(order_date), MONTH(order_date)
. . . . . . . . . . . . . . . . . . . .> ),
. . . . . . . . . . . . . . . . . . . .> ventanas AS (
. . . . . . . . . . . . . . . . . . . .>     SELECT
. . . . . . . . . . . . . . . . . . . .>         *,
. . . . . . . . . . . . . . . . . . . .>         LAG(periodo, 1) OVER (ORDER BY periodo) AS periodo_previo,
. . . . . . . . . . . . . . . . . . . .>         LAG(ventas, 1) OVER (ORDER BY periodo) AS ventas_mes_anterior,
. . . . . . . . . . . . . . . . . . . .>         LAG(ganancias, 1) OVER (ORDER BY periodo)
. . . . . . . . . . . . . . . . . . . .>             AS ganancias_mes_anterior,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>         AVG(ventas) OVER (
. . . . . . . . . . . . . . . . . . . .>             ORDER BY periodo
. . . . . . . . . . . . . . . . . . . .>             ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
. . . . . . . . . . . . . . . . . . . .>         ) AS promedio_ventas_3m,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>         AVG(ganancias) OVER (
. . . . . . . . . . . . . . . . . . . .>             ORDER BY periodo
. . . . . . . . . . . . . . . . . . . .>             ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
. . . . . . . . . . . . . . . . . . . .>         ) AS promedio_ganancias_3m,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>         COUNT(*) OVER (
. . . . . . . . . . . . . . . . . . . .>             ORDER BY periodo
. . . . . . . . . . . . . . . . . . . .>             ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
. . . . . . . . . . . . . . . . . . . .>         ) AS meses_ventana,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>         LAG(periodo, 2) OVER (ORDER BY periodo) AS periodo_hace_dos,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>         ROW_NUMBER() OVER (
. . . . . . . . . . . . . . . . . . . .>             ORDER BY ventas DESC, periodo
. . . . . . . . . . . . . . . . . . . .>         ) AS ranking_mayor_venta,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>         ROW_NUMBER() OVER (
. . . . . . . . . . . . . . . . . . . .>             ORDER BY ventas ASC, periodo
. . . . . . . . . . . . . . . . . . . .>         ) AS ranking_menor_venta
. . . . . . . . . . . . . . . . . . . .>     FROM mensual
. . . . . . . . . . . . . . . . . . . .> ),
. . . . . . . . . . . . . . . . . . . .> comparacion AS (
. . . . . . . . . . . . . . . . . . . .>     SELECT
. . . . . . . . . . . . . . . . . . . .>         a.*,
. . . . . . . . . . . . . . . . . . . .>         b.ventas AS ventas_mismo_mes_anterior,
. . . . . . . . . . . . . . . . . . . .>         b.ganancias AS ganancias_mismo_mes_anterior
. . . . . . . . . . . . . . . . . . . .>     FROM ventanas a
. . . . . . . . . . . . . . . . . . . .>     LEFT JOIN mensual b
. . . . . . . . . . . . . . . . . . . .>         ON a.mes = b.mes
. . . . . . . . . . . . . . . . . . . .>        AND a.anio = b.anio + 1
. . . . . . . . . . . . . . . . . . . .> )
. . . . . . . . . . . . . . . . . . . .> SELECT
. . . . . . . . . . . . . . . . . . . .>     anio,
. . . . . . . . . . . . . . . . . . . .>     mes,
. . . . . . . . . . . . . . . . . . . .>     ROUND(ventas, 2) AS ventas_mensuales,
. . . . . . . . . . . . . . . . . . . .>     ROUND(ganancias, 2) AS ganancias_mensuales,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>     CASE
. . . . . . . . . . . . . . . . . . . .>         WHEN periodo_previo = periodo - 1
. . . . . . . . . . . . . . . . . . . .>          AND ventas_mes_anterior <> 0
. . . . . . . . . . . . . . . . . . . .>         THEN ROUND(
. . . . . . . . . . . . . . . . . . . .>             100.0 * (ventas - ventas_mes_anterior)
. . . . . . . . . . . . . . . . . . . .>             / ABS(ventas_mes_anterior), 2
. . . . . . . . . . . . . . . . . . . .>         )
. . . . . . . . . . . . . . . . . . . .>     END AS variacion_ventas_mensual_pct,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>     CASE
. . . . . . . . . . . . . . . . . . . .>         WHEN periodo_previo = periodo - 1
. . . . . . . . . . . . . . . . . . . .>          AND ganancias_mes_anterior <> 0
. . . . . . . . . . . . . . . . . . . .>         THEN ROUND(
. . . . . . . . . . . . . . . . . . . .>             100.0 * (ganancias - ganancias_mes_anterior)
. . . . . . . . . . . . . . . . . . . .>             / ABS(ganancias_mes_anterior), 2
. . . . . . . . . . . . . . . . . . . .>         )
. . . . . . . . . . . . . . . . . . . .>     END AS variacion_ganancias_mensual_pct,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>     ROUND(ventas_mismo_mes_anterior, 2)
. . . . . . . . . . . . . . . . . . . .>         AS ventas_mismo_mes_anio_anterior,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>     ROUND(ganancias_mismo_mes_anterior, 2)
. . . . . . . . . . . . . . . . . . . .>         AS ganancias_mismo_mes_anio_anterior,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>     CASE
. . . . . . . . . . . . . . . . . . . .>         WHEN ventas_mismo_mes_anterior <> 0
. . . . . . . . . . . . . . . . . . . .>         THEN ROUND(
. . . . . . . . . . . . . . . . . . . .>             100.0 * (ventas - ventas_mismo_mes_anterior)
. . . . . . . . . . . . . . . . . . . .>             / ABS(ventas_mismo_mes_anterior), 2
. . . . . . . . . . . . . . . . . . . .>         )
. . . . . . . . . . . . . . . . . . . .>     END AS variacion_ventas_interanual_pct,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>     CASE
. . . . . . . . . . . . . . . . . . . .>         WHEN ganancias_mismo_mes_anterior <> 0
. . . . . . . . . . . . . . . . . . . .>         THEN ROUND(
. . . . . . . . . . . . . . . . . . . .>             100.0 * (ganancias - ganancias_mismo_mes_anterior)
. . . . . . . . . . . . . . . . . . . .>             / ABS(ganancias_mismo_mes_anterior), 2
. . . . . . . . . . . . . . . . . . . .>         )
. . . . . . . . . . . . . . . . . . . .>     END AS variacion_ganancias_interanual_pct,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>     CASE
. . . . . . . . . . . . . . . . . . . .>         WHEN meses_ventana = 3
. . . . . . . . . . . . . . . . . . . .>          AND periodo_hace_dos = periodo - 2
. . . . . . . . . . . . . . . . . . . .>         THEN ROUND(promedio_ventas_3m, 2)
. . . . . . . . . . . . . . . . . . . .>     END AS promedio_movil_ventas_3m,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>     CASE
. . . . . . . . . . . . . . . . . . . .>         WHEN meses_ventana = 3
. . . . . . . . . . . . . . . . . . . .>          AND periodo_hace_dos = periodo - 2
. . . . . . . . . . . . . . . . . . . .>         THEN ROUND(promedio_ganancias_3m, 2)
. . . . . . . . . . . . . . . . . . . .>     END AS promedio_movil_ganancias_3m,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>     ranking_mayor_venta,
. . . . . . . . . . . . . . . . . . . .>     ranking_menor_venta,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>     CASE
. . . . . . . . . . . . . . . . . . . .>         WHEN ranking_mayor_venta <= 3 THEN 'TOP 3 MAYOR VENTA'
. . . . . . . . . . . . . . . . . . . .>         WHEN ranking_menor_venta <= 3 THEN 'TOP 3 MENOR VENTA'
. . . . . . . . . . . . . . . . . . . .>         ELSE 'INTERMEDIO'
. . . . . . . . . . . . . . . . . . . .>     END AS clasificacion_mes
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .> FROM comparacion
. . . . . . . . . . . . . . . . . . . .> ORDER BY anio, mes;
WARNING: Hive-on-MR is deprecated in Hive 2 and may not be available in the future versions. Consider using a different execution engine (i.e. spark, tez) or using Hive 1.X releases.
SLF4J: Class path contains multiple SLF4J bindings.
SLF4J: Found binding in [jar:file:/opt/hive/lib/log4j-slf4j-impl-2.6.2.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: Found binding in [jar:file:/opt/hadoop-2.7.4/share/hadoop/common/lib/slf4j-log4j12-1.7.10.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
SLF4J: Actual binding is of type [org.apache.logging.slf4j.Log4jLoggerFactory]
Execution log at: /tmp/root/root_20261111162543_230c19d8-2614-4ca1-b093-49d02c5561f3.log
2026-11-11 16:25:52     Starting to launch local task to process map join;      maximum memory = 477626368
2026-11-11 16:25:52     Dump the side-table for tag: 1 with group count: 48 into file: file:/tmp/root/86aa1108-d7cd-4a84-9e98-1af22e6b1287/hive_2026-11-11_16-25-43_927_7603811529989812349-16/-local-10010/HashTable-Stage-8/MapJoin-mapfile01--.hashtable
2026-11-11 16:25:52     Uploaded 1 File to: file:/tmp/root/86aa1108-d7cd-4a84-9e98-1af22e6b1287/hive_2026-11-11_16-25-43_927_7603811529989812349-16/-local-10010/HashTable-Stage-8/MapJoin-mapfile01--.hashtable (1891 bytes)
2026-11-11 16:25:52     End of local task; Time Taken: 0.259 sec.
+-------+------+-------------------+----------------------+-------------------------------+----------------------------------+---------------------------------+------------------------------------+----------------------------------+-------------------------------------+---------------------------+------------------------------+----------------------+----------------------+--------------------+
| anio  | mes  | ventas_mensuales  | ganancias_mensuales  | variacion_ventas_mensual_pct  | variacion_ganancias_mensual_pct  | ventas_mismo_mes_anio_anterior  | ganancias_mismo_mes_anio_anterior  | variacion_ventas_interanual_pct  | variacion_ganancias_interanual_pct  | promedio_movil_ventas_3m  | promedio_movil_ganancias_3m  | ranking_mayor_venta  | ranking_menor_venta  | clasificacion_mes  |
+-------+------+-------------------+----------------------+-------------------------------+----------------------------------+---------------------------------+------------------------------------+----------------------------------+-------------------------------------+---------------------------+------------------------------+----------------------+----------------------+--------------------+
| 2014  | 1    | 14236.90          | 2450.19              | NULL                          | NULL                             | NULL                            | NULL                               | NULL                             | NULL                                | NULL                      | NULL                         | 46                   | 3                    | TOP 3 MENOR VENTA  |
| 2014  | 2    | 4519.89           | 862.31               | -68.25                        | -64.81                           | NULL                            | NULL                               | NULL                             | NULL                                | NULL                      | NULL                         | 48                   | 1                    | TOP 3 MENOR VENTA  |
| 2014  | 3    | 55691.01          | 498.73               | 1132.13                       | -42.16                           | NULL                            | NULL                               | NULL                             | NULL                                | 24815.93                  | 1270.41                      | 18                   | 31                   | INTERMEDIO         |
| 2014  | 4    | 28295.35          | 3488.84              | -49.19                        | 599.54                           | NULL                            | NULL                               | NULL                             | NULL                                | 29502.08                  | 1616.62                      | 38                   | 11                   | INTERMEDIO         |
| 2014  | 5    | 23648.29          | 2738.71              | -16.42                        | -21.50                           | NULL                            | NULL                               | NULL                             | NULL                                | 35878.21                  | 2242.09                      | 41                   | 8                    | INTERMEDIO         |
| 2014  | 6    | 34595.13          | 4976.52              | 46.29                         | 81.71                            | NULL                            | NULL                               | NULL                             | NULL                                | 28846.25                  | 3734.69                      | 30                   | 19                   | INTERMEDIO         |
| 2014  | 7    | 33946.39          | -841.48              | -1.88                         | -116.91                          | NULL                            | NULL                               | NULL                             | NULL                                | 30729.94                  | 2291.25                      | 32                   | 17                   | INTERMEDIO         |
| 2014  | 8    | 27909.47          | 5318.11              | -17.78                        | 731.99                           | NULL                            | NULL                               | NULL                             | NULL                                | 32150.33                  | 3151.05                      | 39                   | 10                   | INTERMEDIO         |
| 2014  | 9    | 81777.35          | 8328.10              | 193.01                        | 56.60                            | NULL                            | NULL                               | NULL                             | NULL                                | 47877.74                  | 4268.24                      | 5                    | 44                   | INTERMEDIO         |
| 2014  | 10   | 31453.39          | 3448.26              | -61.54                        | -58.59                           | NULL                            | NULL                               | NULL                             | NULL                                | 47046.74                  | 5698.15                      | 33                   | 16                   | INTERMEDIO         |
| 2014  | 11   | 78628.72          | 9292.13              | 149.98                        | 169.47                           | NULL                            | NULL                               | NULL                             | NULL                                | 63953.15                  | 7022.83                      | 7                    | 42                   | INTERMEDIO         |
| 2014  | 12   | 69545.62          | 8983.57              | -11.55                        | -3.32                            | NULL                            | NULL                               | NULL                             | NULL                                | 59875.91                  | 7241.32                      | 12                   | 37                   | INTERMEDIO         |
| 2015  | 1    | 18174.08          | -3281.01             | -73.87                        | -136.52                          | 14236.90                        | 2450.19                            | 27.65                            | -233.91                             | 55449.47                  | 4998.23                      | 45                   | 4                    | INTERMEDIO         |
| 2015  | 2    | 11951.41          | 2813.85              | -34.24                        | 185.76                           | 4519.89                         | 862.31                             | 164.42                           | 226.32                              | 33223.70                  | 2838.80                      | 47                   | 2                    | TOP 3 MENOR VENTA  |
| 2015  | 3    | 38726.25          | 9732.10              | 224.03                        | 245.86                           | 55691.01                        | 498.73                             | -30.46                           | 1851.38                             | 22950.58                  | 3088.31                      | 27                   | 22                   | INTERMEDIO         |
| 2015  | 4    | 34195.21          | 4187.50              | -11.70                        | -56.97                           | 28295.35                        | 3488.84                            | 20.85                            | 20.03                               | 28290.96                  | 5577.81                      | 31                   | 18                   | INTERMEDIO         |
| 2015  | 5    | 30131.69          | 4667.87              | -11.88                        | 11.47                            | 23648.29                        | 2738.71                            | 27.42                            | 70.44                               | 34351.05                  | 6195.82                      | 36                   | 13                   | INTERMEDIO         |
| 2015  | 6    | 24797.29          | 3335.56              | -17.70                        | -28.54                           | 34595.13                        | 4976.52                            | -28.32                           | -32.97                              | 29708.06                  | 4063.64                      | 40                   | 9                    | INTERMEDIO         |
| 2015  | 7    | 28765.33          | 3288.65              | 16.00                         | -1.41                            | 33946.39                        | -841.48                            | -15.26                           | 490.82                              | 27898.10                  | 3764.02                      | 37                   | 12                   | INTERMEDIO         |
| 2015  | 8    | 36898.33          | 5355.81              | 28.27                         | 62.86                            | 27909.47                        | 5318.11                            | 32.21                            | 0.71                                | 30153.65                  | 3993.34                      | 28                   | 21                   | INTERMEDIO         |
| 2015  | 9    | 64595.92          | 8209.16              | 75.06                         | 53.28                            | 81777.35                        | 8328.10                            | -21.01                           | -1.43                               | 43419.86                  | 5617.87                      | 13                   | 36                   | INTERMEDIO         |
| 2015  | 10   | 31404.92          | 2817.37              | -51.38                        | -65.68                           | 31453.39                        | 3448.26                            | -0.15                            | -18.30                              | 44299.72                  | 5460.78                      | 34                   | 15                   | INTERMEDIO         |
| 2015  | 11   | 75972.56          | 12474.79             | 141.91                        | 342.78                           | 78628.72                        | 9292.13                            | -3.38                            | 34.25                               | 57324.47                  | 7833.77                      | 9                    | 40                   | INTERMEDIO         |
| 2015  | 12   | 74919.52          | 8016.97              | -1.39                         | -35.73                           | 69545.62                        | 8983.57                            | 7.73                             | -10.76                              | 60765.67                  | 7769.71                      | 10                   | 39                   | INTERMEDIO         |
| 2016  | 1    | 18542.49          | 2824.82              | -75.25                        | -64.76                           | 18174.08                        | -3281.01                           | 2.03                             | 186.10                              | 56478.19                  | 7772.19                      | 44                   | 5                    | INTERMEDIO         |
| 2016  | 2    | 22978.82          | 5004.58              | 23.93                         | 77.16                            | 11951.41                        | 2813.85                            | 92.27                            | 77.86                               | 38813.61                  | 5282.12                      | 42                   | 7                    | INTERMEDIO         |
| 2016  | 3    | 51715.88          | 3611.97              | 125.06                        | -27.83                           | 38726.25                        | 9732.10                            | 33.54                            | -62.89                              | 31079.06                  | 3813.79                      | 20                   | 29                   | INTERMEDIO         |
| 2016  | 4    | 38750.04          | 2977.81              | -25.07                        | -17.56                           | 34195.21                        | 4187.50                            | 13.32                            | -28.89                              | 37814.91                  | 3864.79                      | 26                   | 23                   | INTERMEDIO         |
| 2016  | 5    | 56987.73          | 8662.15              | 47.06                         | 190.89                           | 30131.69                        | 4667.87                            | 89.13                            | 85.57                               | 49151.21                  | 5083.98                      | 17                   | 32                   | INTERMEDIO         |
| 2016  | 6    | 40344.53          | 4750.38              | -29.20                        | -45.16                           | 24797.29                        | 3335.56                            | 62.70                            | 42.42                               | 45360.77                  | 5463.45                      | 24                   | 25                   | INTERMEDIO         |
| 2016  | 7    | 39261.96          | 4432.88              | -2.68                         | -6.68                            | 28765.33                        | 3288.65                            | 36.49                            | 34.79                               | 45531.41                  | 5948.47                      | 25                   | 24                   | INTERMEDIO         |
| 2016  | 8    | 31115.37          | 2062.07              | -20.75                        | -53.48                           | 36898.33                        | 5355.81                            | -15.67                           | -61.50                              | 36907.29                  | 3748.44                      | 35                   | 14                   | INTERMEDIO         |
| 2016  | 9    | 73410.02          | 9328.66              | 135.93                        | 352.39                           | 64595.92                        | 8209.16                            | 13.64                            | 13.64                               | 47929.12                  | 5274.53                      | 11                   | 38                   | INTERMEDIO         |
| 2016  | 10   | 59687.75          | 16243.14             | -18.69                        | 74.12                            | 31404.92                        | 2817.37                            | 90.06                            | 476.54                              | 54737.71                  | 9211.29                      | 15                   | 34                   | INTERMEDIO         |
| 2016  | 11   | 79411.97          | 4011.41              | 33.05                         | -75.30                           | 75972.56                        | 12474.79                           | 4.53                             | -67.84                              | 70836.58                  | 9861.07                      | 6                    | 43                   | INTERMEDIO         |
| 2016  | 12   | 96999.04          | 17885.31             | 22.15                         | 345.86                           | 74919.52                        | 8016.97                            | 29.47                            | 123.09                              | 78699.58                  | 12713.29                     | 2                    | 47                   | TOP 3 MAYOR VENTA  |
| 2017  | 1    | 43971.37          | 7140.44              | -54.67                        | -60.08                           | 18542.49                        | 2824.82                            | 137.14                           | 152.77                              | 73460.79                  | 9679.05                      | 23                   | 26                   | INTERMEDIO         |
| 2017  | 2    | 20301.13          | 1613.87              | -53.83                        | -77.40                           | 22978.82                        | 5004.58                            | -11.65                           | -67.75                              | 53757.18                  | 8879.87                      | 43                   | 6                    | INTERMEDIO         |
| 2017  | 3    | 58872.35          | 14751.89             | 190.00                        | 814.07                           | 51715.88                        | 3611.97                            | 13.84                            | 308.42                              | 41048.29                  | 7835.40                      | 16                   | 33                   | INTERMEDIO         |
| 2017  | 4    | 36521.54          | 933.29               | -37.96                        | -93.67                           | 38750.04                        | 2977.81                            | -5.75                            | -68.66                              | 38565.01                  | 5766.35                      | 29                   | 20                   | INTERMEDIO         |
| 2017  | 5    | 44261.11          | 6342.58              | 21.19                         | 579.59                           | 56987.73                        | 8662.15                            | -22.33                           | -26.78                              | 46551.67                  | 7342.59                      | 22                   | 27                   | INTERMEDIO         |
| 2017  | 6    | 52981.73          | 8223.34              | 19.70                         | 29.65                            | 40344.53                        | 4750.38                            | 31.32                            | 73.11                               | 44588.12                  | 5166.40                      | 19                   | 30                   | INTERMEDIO         |
| 2017  | 7    | 45264.42          | 6952.62              | -14.57                        | -15.45                           | 39261.96                        | 4432.88                            | 15.29                            | 56.84                               | 47502.42                  | 7172.85                      | 21                   | 28                   | INTERMEDIO         |
| 2017  | 8    | 63120.89          | 9040.96              | 39.45                         | 30.04                            | 31115.37                        | 2062.07                            | 102.86                           | 338.44                              | 53789.01                  | 8072.30                      | 14                   | 35                   | INTERMEDIO         |
| 2017  | 9    | 87866.65          | 10991.56             | 39.20                         | 21.58                            | 73410.02                        | 9328.66                            | 19.69                            | 17.83                               | 65417.32                  | 8995.04                      | 3                    | 46                   | TOP 3 MAYOR VENTA  |
| 2017  | 10   | 77776.92          | 9275.28              | -11.48                        | -15.61                           | 59687.75                        | 16243.14                           | 30.31                            | -42.90                              | 76254.82                  | 9769.26                      | 8                    | 41                   | INTERMEDIO         |
| 2017  | 11   | 118447.83         | 9690.10              | 52.29                         | 4.47                             | 79411.97                        | 4011.41                            | 49.16                            | 141.56                              | 94697.13                  | 9985.64                      | 1                    | 48                   | TOP 3 MAYOR VENTA  |
| 2017  | 12   | 83829.32          | 8483.35              | -29.23                        | -12.45                           | 96999.04                        | 17885.31                           | -13.58                           | -52.57                              | 93351.36                  | 9149.58                      | 4                    | 45                   | INTERMEDIO         |
+-------+------+-------------------+----------------------+-------------------------------+----------------------------------+---------------------------------+------------------------------------+----------------------------------+-------------------------------------+---------------------------+------------------------------+----------------------+----------------------+--------------------+
48 rows selected (11.165 seconds)
0: jdbc:hive2://localhost:10000/default> 