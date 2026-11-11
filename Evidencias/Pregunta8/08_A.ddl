a) Determine qué cantidad de productos representa el 80% de las ventas acumuladas.

0: jdbc:hive2://localhost:10000/default> SELECT
. . . . . . . . . . . . . . . . . . . .>     analisis,
. . . . . . . . . . . . . . . . . . . .>     MAX(total_productos) AS total_productos,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>     SUM(pertenece_80) AS productos_para_80_pct,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>     ROUND(
. . . . . . . . . . . . . . . . . . . .>         100.0 * SUM(pertenece_80) / MAX(total_productos), 2
. . . . . . . . . . . . . . . . . . . .>     ) AS porcentaje_del_catalogo,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>     ROUND(MAX(total_contribucion), 2) AS total_economico,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>     ROUND(
. . . . . . . . . . . . . . . . . . . .>         SUM(CASE WHEN pertenece_80 = 1
. . . . . . . . . . . . . . . . . . . .>             THEN contribucion ELSE 0 END), 2
. . . . . . . . . . . . . . . . . . . .>     ) AS importe_grupo_pareto,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>     CASE
. . . . . . . . . . . . . . . . . . . .>         WHEN MAX(total_contribucion) > 0
. . . . . . . . . . . . . . . . . . . .>         THEN ROUND(
. . . . . . . . . . . . . . . . . . . .>             100.0 * SUM(
. . . . . . . . . . . . . . . . . . . .>                 CASE WHEN pertenece_80 = 1
. . . . . . . . . . . . . . . . . . . .>                     THEN contribucion ELSE 0 END
. . . . . . . . . . . . . . . . . . . .>             ) / MAX(total_contribucion), 2
. . . . . . . . . . . . . . . . . . . .>         )
. . . . . . . . . . . . . . . . . . . .>     END AS porcentaje_economico_alcanzado
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .> FROM pareto_superstore
. . . . . . . . . . . . . . . . . . . .> GROUP BY analisis
. . . . . . . . . . . . . . . . . . . .> ORDER BY analisis;
WARNING: Hive-on-MR is deprecated in Hive 2 and may not be available in the future versions. Consider using a different execution engine (i.e. spark, tez) or using Hive 1.X releases.
+------------+------------------+------------------------+--------------------------+------------------+-----------------------+---------------------------------+
|  analisis  | total_productos  | productos_para_80_pct  | porcentaje_del_catalogo  | total_economico  | importe_grupo_pareto  | porcentaje_economico_alcanzado  |
+------------+------------------+------------------------+--------------------------+------------------+-----------------------+---------------------------------+
| GANANCIAS  | 1862             | 164                    | 8.81                     | 286397.02        | 229204.39             | 80.03                           |
| VENTAS     | 1862             | 414                    | 22.23                    | 2297200.86       | 1838610.14            | 80.04                           |
+------------+------------------+------------------------+--------------------------+------------------+-----------------------+---------------------------------+
2 rows selected (7.08 seconds)
0: jdbc:hive2://localhost:10000/default> 