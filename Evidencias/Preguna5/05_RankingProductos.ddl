0: jdbc:hive2://localhost:10000/default> WITH productos AS (
. . . . . . . . . . . . . . . . . . . .>     SELECT
. . . . . . . . . . . . . . . . . . . .>         category,
. . . . . . . . . . . . . . . . . . . .>         product_id,
. . . . . . . . . . . . . . . . . . . .>         MAX(product_name) AS product_name,
. . . . . . . . . . . . . . . . . . . .>         SUM(quantity) AS unidades_vendidas,
. . . . . . . . . . . . . . . . . . . .>         SUM(sales) AS ventas_totales,
. . . . . . . . . . . . . . . . . . . .>         SUM(profit) AS ganancia_total,
. . . . . . . . . . . . . . . . . . . .>         CASE
. . . . . . . . . . . . . . . . . . . .>             WHEN SUM(sales) <> 0
. . . . . . . . . . . . . . . . . . . .>             THEN 100.0 * SUM(profit) / SUM(sales)
. . . . . . . . . . . . . . . . . . . .>         END AS margen_pct
. . . . . . . . . . . . . . . . . . . .>     FROM superstore_analitica
. . . . . . . . . . . . . . . . . . . .>     WHERE product_id IS NOT NULL
. . . . . . . . . . . . . . . . . . . .>       AND TRIM(product_id) <> ''
. . . . . . . . . . . . . . . . . . . .>     GROUP BY category, product_id
. . . . . . . . . . . . . . . . . . . .> ),
. . . . . . . . . . . . . . . . . . . .> posiciones AS (
. . . . . . . . . . . . . . . . . . . .>     SELECT
. . . . . . . . . . . . . . . . . . . .>         *,
. . . . . . . . . . . . . . . . . . . .>         RANK() OVER (
. . . . . . . . . . . . . . . . . . . .>             PARTITION BY category
. . . . . . . . . . . . . . . . . . . .>             ORDER BY ganancia_total DESC
. . . . . . . . . . . . . . . . . . . .>         ) AS posicion_categoria,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>         DENSE_RANK() OVER (
. . . . . . . . . . . . . . . . . . . .>             PARTITION BY category
. . . . . . . . . . . . . . . . . . . .>             ORDER BY ganancia_total DESC
. . . . . . . . . . . . . . . . . . . .>         ) AS nivel_ganancia_categoria,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>         ROW_NUMBER() OVER (
. . . . . . . . . . . . . . . . . . . .>             PARTITION BY category
. . . . . . . . . . . . . . . . . . . .>             ORDER BY ganancia_total DESC, product_id
. . . . . . . . . . . . . . . . . . . .>         ) AS orden_top_categoria,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>         ROW_NUMBER() OVER (
. . . . . . . . . . . . . . . . . . . .>             ORDER BY unidades_vendidas DESC, product_id, category
. . . . . . . . . . . . . . . . . . . .>         ) AS posicion_volumen,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>         ROW_NUMBER() OVER (
. . . . . . . . . . . . . . . . . . . .>             ORDER BY
. . . . . . . . . . . . . . . . . . . .>                 CASE WHEN margen_pct IS NULL THEN 1 ELSE 0 END,
. . . . . . . . . . . . . . . . . . . .>                 margen_pct ASC,
. . . . . . . . . . . . . . . . . . . .>                 product_id,
. . . . . . . . . . . . . . . . . . . .>                 category
. . . . . . . . . . . . . . . . . . . .>         ) AS posicion_menor_margen,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>         SUM(ganancia_total) OVER (
. . . . . . . . . . . . . . . . . . . .>             PARTITION BY category
. . . . . . . . . . . . . . . . . . . .>             ORDER BY ganancia_total DESC, product_id
. . . . . . . . . . . . . . . . . . . .>             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
. . . . . . . . . . . . . . . . . . . .>         ) AS ganancia_acumulada_categoria
. . . . . . . . . . . . . . . . . . . .>     FROM productos
. . . . . . . . . . . . . . . . . . . .> )
. . . . . . . . . . . . . . . . . . . .> SELECT
. . . . . . . . . . . . . . . . . . . .>     category,
. . . . . . . . . . . . . . . . . . . .>     product_id,
. . . . . . . . . . . . . . . . . . . .>     product_name,
. . . . . . . . . . . . . . . . . . . .>     unidades_vendidas,
. . . . . . . . . . . . . . . . . . . .>     ROUND(ventas_totales, 2) AS ventas_totales,
. . . . . . . . . . . . . . . . . . . .>     ROUND(ganancia_total, 2) AS ganancia_total,
. . . . . . . . . . . . . . . . . . . .>     ROUND(margen_pct, 2) AS margen_ganancia_pct,
. . . . . . . . . . . . . . . . . . . .>     posicion_categoria,
. . . . . . . . . . . . . . . . . . . .>     nivel_ganancia_categoria,
. . . . . . . . . . . . . . . . . . . .>     ROUND(ganancia_acumulada_categoria, 2)
. . . . . . . . . . . . . . . . . . . .>         AS ganancia_acumulada_categoria,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>     CASE WHEN orden_top_categoria <= 5
. . . . . . . . . . . . . . . . . . . .>         THEN 'SI' ELSE 'NO'
. . . . . . . . . . . . . . . . . . . .>     END AS top5_ganancia_categoria,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>     posicion_volumen,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>     CASE WHEN posicion_volumen <= 5
. . . . . . . . . . . . . . . . . . . .>         THEN 'SI' ELSE 'NO'
. . . . . . . . . . . . . . . . . . . .>     END AS top5_unidades,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>     posicion_menor_margen,
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .>     CASE WHEN posicion_menor_margen <= 5
. . . . . . . . . . . . . . . . . . . .>               AND margen_pct IS NOT NULL
. . . . . . . . . . . . . . . . . . . .>         THEN 'SI' ELSE 'NO'
. . . . . . . . . . . . . . . . . . . .>     END AS top5_menor_rentabilidad
. . . . . . . . . . . . . . . . . . . .> 
. . . . . . . . . . . . . . . . . . . .> FROM posiciones
. . . . . . . . . . . . . . . . . . . .> WHERE orden_top_categoria <= 5
. . . . . . . . . . . . . . . . . . . .>    OR posicion_volumen <= 5
. . . . . . . . . . . . . . . . . . . .>    OR (posicion_menor_margen <= 5 AND margen_pct IS NOT NULL)
. . . . . . . . . . . . . . . . . . . .> ORDER BY category, posicion_categoria, product_id;
WARNING: Hive-on-MR is deprecated in Hive 2 and may not be available in the future versions. Consider using a different execution engine (i.e. spark, tez) or using Hive 1.X releases.
+------------------+------------------+----------------------------------------------------+--------------------+-----------------+-----------------+----------------------+---------------------+---------------------------+-------------------------------+--------------------------+-------------------+----------------+------------------------+--------------------------+
|     category     |    product_id    |                    product_name                    | unidades_vendidas  | ventas_totales  | ganancia_total  | margen_ganancia_pct  | posicion_categoria  | nivel_ganancia_categoria  | ganancia_acumulada_categoria  | top5_ganancia_categoria  | posicion_volumen  | top5_unidades  | posicion_menor_margen  | top5_menor_rentabilidad  |
+------------------+------------------+----------------------------------------------------+--------------------+-----------------+-----------------+----------------------+---------------------+---------------------------+-------------------------------+--------------------------+-------------------+----------------+------------------------+--------------------------+
| Furniture        | FUR-CH-10000454  | Hon Deluxe Fabric Upholstered Stacking Chairs, Rounded Back | 51                 | 10637.53        | 1927.44         | 18.12                | 1                   | 1                         | 1927.44                       | SI                       | 19                | NO             | 772                    | NO                       |
| Furniture        | FUR-CH-10004063  | Global Deluxe High-Back Manager's Chair            | 35                 | 8665.19         | 1558.59         | 17.99                | 2                   | 2                         | 3486.03                       | SI                       | 187               | NO             | 766                    | NO                       |
| Furniture        | FUR-CH-10002320  | Hon Pagoda Stacking Chairs                         | 22                 | 6483.80         | 1540.70         | 23.76                | 3                   | 3                         | 5026.74                       | SI                       | 696               | NO             | 979                    | NO                       |
| Furniture        | FUR-CH-10004086  | Hon 4070 Series Pagoda Armless Upholstered Stacking Chairs | 34                 | 8431.00         | 1388.63         | 16.47                | 4                   | 4                         | 6415.37                       | SI                       | 216               | NO             | 705                    | NO                       |
| Furniture        | FUR-CH-10001854  | Office Star - Professional Matrix Back Chair with 2-to-1 Synchro Tilt and Mesh Fabric Seat | 28                 | 8774.50         | 1305.65         | 14.88                | 5                   | 5                         | 7721.02                       | SI                       | 404               | NO             | 658                    | NO                       |
| Furniture        | FUR-CH-10002647  | Situations Contoured Folding Chairs, 4/Set         | 64                 | 3641.27         | 234.23          | 6.43                 | 70                  | 70                        | 42723.71                      | NO                       | 4                 | SI             | 425                    | NO                       |
| Furniture        | FUR-BO-10001567  | Bush Westfield Collection Bookcases, Dark Cherry Finish, Fully Assembled | 3                  | 90.88           | -190.85         | -210.00              | 318                 | 317                       | 50324.82                      | NO                       | 1805              | NO             | 2                      | SI                       |
| Office Supplies  | OFF-BI-10003527  | Fellowes PB500 Electric Punch Plastic Comb Binding Machine with Manual Bind | 31                 | 27453.38        | 7753.04         | 28.24                | 1                   | 1                         | 7753.04                       | SI                       | 314               | NO             | 1140                   | NO                       |
| Office Supplies  | OFF-BI-10001120  | Ibico EPK-21 Electric Binding System               | 13                 | 15875.92        | 3345.28         | 21.07                | 2                   | 2                         | 11098.32                      | SI                       | 1327              | NO             | 866                    | NO                       |
| Office Supplies  | OFF-AP-10002945  | Honeywell Enviracaire Portable HEPA Air Cleaner for 17' x 22' Room | 40                 | 11304.44        | 3247.02         | 28.72                | 3                   | 3                         | 14345.34                      | SI                       | 109               | NO             | 1146                   | NO                       |
| Office Supplies  | OFF-BI-10003925  | Fellowes PB300 Plastic Comb Binding Machine        | 27                 | 8070.19         | 2518.06         | 31.20                | 4                   | 4                         | 16863.40                      | SI                       | 460               | NO             | 1213                   | NO                       |
| Office Supplies  | OFF-BI-10004600  | Ibico Ibimaster 300 Manual Binding System          | 28                 | 7985.38         | 2318.34         | 29.03                | 5                   | 5                         | 19181.73                      | SI                       | 416               | NO             | 1166                   | NO                       |
| Office Supplies  | OFF-PA-10001970  | Xerox 1908                                         | 70                 | 2167.35         | 1006.44         | 46.44                | 24                  | 24                        | 46760.12                      | NO                       | 2                 | SI             | 1768                   | NO                       |
| Office Supplies  | OFF-BI-10002026  | Ibico Recycled Linen-Style Covers                  | 64                 | 2068.82         | 349.63          | 16.90                | 89                  | 89                        | 80673.84                      | NO                       | 5                 | SI             | 721                    | NO                       |
| Office Supplies  | OFF-BI-10001524  | GBC Premium Transparent Covers with Diagonal Lined Pattern | 67                 | 780.46          | 49.51           | 6.34                 | 451                 | 450                       | 123997.40                     | NO                       | 3                 | SI             | 422                    | NO                       |
| Office Supplies  | OFF-AP-10002203  | Eureka Disposable Bags for Sanitaire Vibra Groomer I Upright Vac | 2                  | 1.62            | -4.47           | -275.00              | 985                 | 975                       | 135044.30                     | NO                       | 1842              | NO             | 1                      | SI                       |
| Office Supplies  | OFF-AP-10000390  | Euro Pro Shark Stick Mini Vacuum                   | 11                 | 170.74          | -325.63         | -190.71              | 1073                | 1063                      | 130104.78                     | NO                       | 1455              | NO             | 3                      | SI                       |
| Technology       | TEC-CO-10004722  | Canon imageCLASS 2200 Advanced Copier              | 20                 | 61599.82        | 25199.93        | 40.91                | 1                   | 1                         | 25199.93                      | SI                       | 879               | NO             | 1511                   | NO                       |
| Technology       | TEC-CO-10001449  | Hewlett Packard LaserJet 3310 Copier               | 38                 | 18839.69        | 6983.88         | 37.07                | 2                   | 2                         | 32183.81                      | SI                       | 149               | NO             | 1380                   | NO                       |
| Technology       | TEC-CO-10003763  | Canon PC1060 Personal Laser Copier                 | 19                 | 11619.83        | 4570.93         | 39.34                | 3                   | 3                         | 36754.75                      | SI                       | 934               | NO             | 1450                   | NO                       |
| Technology       | TEC-AC-10002049  | Plantronics Savi W720 Multi-Device Wireless Headset System | 60                 | 13756.54        | 4425.34         | 32.17                | 4                   | 4                         | 41180.09                      | SI                       | 7                 | NO             | 1235                   | NO                       |
| Technology       | TEC-MA-10001127  | HP Designjet T520 Inkjet Large Format Printer - 24" Color | 12                 | 18374.90        | 4094.98         | 22.29                | 5                   | 5                         | 45275.07                      | SI                       | 1435              | NO             | 918                    | NO                       |
| Technology       | TEC-AC-10003832  | Logitech?P710e Mobile Speakerphone                 | 75                 | 11203.76        | 1987.93         | 17.74                | 17                  | 17                        | 77660.60                      | NO                       | 1                 | SI             | 753                    | NO                       |
| Technology       | TEC-MA-10003337  | Okidata B401 Printer                               | 3                  | 179.99          | -251.99         | -140.00              | 389                 | 389                       | 170772.27                     | NO                       | 1832              | NO             | 4                      | SI                       |
| Technology       | TEC-MA-10001695  | Zebra GK420t Direct Thermal/Thermal Transfer Printer | 6                  | 703.71          | -938.28         | -133.33              | 399                 | 399                       | 165633.19                     | NO                       | 1714              | NO             | 5                      | SI                       |
+------------------+------------------+----------------------------------------------------+--------------------+-----------------+-----------------+----------------------+---------------------+---------------------------+-------------------------------+--------------------------+-------------------+----------------+------------------------+--------------------------+
25 rows selected (7.035 seconds)
0: jdbc:hive2://localhost:10000/default> 