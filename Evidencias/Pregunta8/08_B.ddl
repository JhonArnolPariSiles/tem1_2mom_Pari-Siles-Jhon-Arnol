0: jdbc:hive2://localhost:10000/default> SELECT
. . . . . . . . . . . . . . . . . . . .>     MAX(total_productos) AS total_productos,
. . . . . . . . . . . . . . . . . . . .>     SUM(pertenece_80) AS productos_para_80_pct_ganancias,
. . . . . . . . . . . . . . . . . . . .>     ROUND(
. . . . . . . . . . . . . . . . . . . .>         100.0 * SUM(pertenece_80) / MAX(total_productos), 2
. . . . . . . . . . . . . . . . . . . .>     ) AS porcentaje_del_catalogo,
. . . . . . . . . . . . . . . . . . . .>     ROUND(
. . . . . . . . . . . . . . . . . . . .>         SUM(CASE WHEN pertenece_80 = 1
. . . . . . . . . . . . . . . . . . . .>             THEN contribucion ELSE 0 END), 2
. . . . . . . . . . . . . . . . . . . .>     ) AS ganancia_acumulada
. . . . . . . . . . . . . . . . . . . .> FROM pareto_superstore
. . . . . . . . . . . . . . . . . . . .> WHERE analisis = 'GANANCIAS';
WARNING: Hive-on-MR is deprecated in Hive 2 and may not be available in the future versions. Consider using a different execution engine (i.e. spark, tez) or using Hive 1.X releases.
+------------------+----------------------------------+--------------------------+---------------------+
| total_productos  | productos_para_80_pct_ganancias  | porcentaje_del_catalogo  | ganancia_acumulada  |
+------------------+----------------------------------+--------------------------+---------------------+
| 1862             | 164                              | 8.81                     | 229204.39           |
+------------------+----------------------------------+--------------------------+---------------------+
1 row selected (6.004 seconds)
0: jdbc:hive2://localhost:10000/default> 