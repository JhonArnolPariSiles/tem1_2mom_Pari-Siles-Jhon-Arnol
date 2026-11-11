///Cantidad total de registros.

0: jdbc:hive2://localhost:10000/default> SELECT COUNT(*) AS total_registros
. . . . . . . . . . . . . . . . . . . .> FROM auditoria_superstore;
WARNING: Hive-on-MR is deprecated in Hive 2 and may not be available in the future versions. Consider using a different execution engine (i.e. spark, tez) or using Hive 1.X releases.
+------------------+
| total_registros  |
+------------------+
| 9994             |
+------------------+
1 row selected (1.338 seconds)
0: jdbc:hive2://localhost:10000/default> 


///Cantidad de identificadores de fila duplicados.

0: jdbc:hive2://localhost:10000/default> SELECT
. . . . . . . . . . . . . . . . . . . .>     COUNT(*) AS identificadores_duplicados,
. . . . . . . . . . . . . . . . . . . .>     COALESCE(SUM(cantidad - 1), 0) AS filas_duplicadas_adicionales
. . . . . . . . . . . . . . . . . . . .> FROM (
. . . . . . . . . . . . . . . . . . . .>     SELECT row_id_num, COUNT(*) AS cantidad
. . . . . . . . . . . . . . . . . . . .>     FROM auditoria_superstore
. . . . . . . . . . . . . . . . . . . .>     WHERE row_id_num IS NOT NULL
. . . . . . . . . . . . . . . . . . . .>     GROUP BY row_id_num
. . . . . . . . . . . . . . . . . . . .>     HAVING COUNT(*) > 1
. . . . . . . . . . . . . . . . . . . .> ) d;
WARNING: Hive-on-MR is deprecated in Hive 2 and may not be available in the future versions. Consider using a different execution engine (i.e. spark, tez) or using Hive 1.X releases.
+-----------------------------+-------------------------------+
| identificadores_duplicados  | filas_duplicadas_adicionales  |
+-----------------------------+-------------------------------+
| 0                           | 0                             |
+-----------------------------+-------------------------------+
1 row selected (2.518 seconds)
0: jdbc:hive2://localhost:10000/default> 

Cantidad de órdenes únicas y clientes únicos.
0: jdbc:hive2://localhost:10000/default> SELECT
. . . . . . . . . . . . . . . . . . . .>     COUNT(DISTINCT CASE
. . . . . . . . . . . . . . . . . . . .>         WHEN TRIM(order_id) <> '' THEN TRIM(order_id)
. . . . . . . . . . . . . . . . . . . .>     END) AS ordenes_unicas,
. . . . . . . . . . . . . . . . . . . .>     COUNT(DISTINCT CASE
. . . . . . . . . . . . . . . . . . . .>         WHEN TRIM(customer_id) <> '' THEN TRIM(customer_id)
. . . . . . . . . . . . . . . . . . . .>     END) AS clientes_unicos
. . . . . . . . . . . . . . . . . . . .> FROM auditoria_superstore;
WARNING: Hive-on-MR is deprecated in Hive 2 and may not be available in the future versions. Consider using a different execution engine (i.e. spark, tez) or using Hive 1.X releases.
+-----------------+------------------+
| ordenes_unicas  | clientes_unicos  |
+-----------------+------------------+
| 5009            | 793              |
+-----------------+------------------+
1 row selected (1.462 seconds)

///Campos que contienen valores NULL.

0: jdbc:hive2://localhost:10000/default> WITH campos AS (
. . . . . . . . . . . . . . . . . . . .>     SELECT campo, valor
. . . . . . . . . . . . . . . . . . . .>     FROM superstore_raw
. . . . . . . . . . . . . . . . . . . .>     LATERAL VIEW STACK(
. . . . . . . . . . . . . . . . . . . .>         21,
. . . . . . . . . . . . . . . . . . . .>         'row_id', row_id,
. . . . . . . . . . . . . . . . . . . .>         'order_id', order_id,
. . . . . . . . . . . . . . . . . . . .>         'order_date', order_date,
. . . . . . . . . . . . . . . . . . . .>         'ship_date', ship_date,
. . . . . . . . . . . . . . . . . . . .>         'ship_mode', ship_mode,
. . . . . . . . . . . . . . . . . . . .>         'customer_id', customer_id,
. . . . . . . . . . . . . . . . . . . .>         'customer_name', customer_name,
. . . . . . . . . . . . . . . . . . . .>         'segment', segment,
. . . . . . . . . . . . . . . . . . . .>         'country', country,
. . . . . . . . . . . . . . . . . . . .>         'city', city,
. . . . . . . . . . . . . . . . . . . .>         'state', state,
. . . . . . . . . . . . . . . . . . . .>         'postal_code', postal_code,
. . . . . . . . . . . . . . . . . . . .>         'region', region,
. . . . . . . . . . . . . . . . . . . .>         'product_id', product_id,
. . . . . . . . . . . . . . . . . . . .>         'category', category,
. . . . . . . . . . . . . . . . . . . .>         'sub_category', sub_category,
. . . . . . . . . . . . . . . . . . . .>         'product_name', product_name,
. . . . . . . . . . . . . . . . . . . .>         'sales', sales,
. . . . . . . . . . . . . . . . . . . .>         'quantity', quantity,
. . . . . . . . . . . . . . . . . . . .>         'discount', discount,
. . . . . . . . . . . . . . . . . . . .>         'profit', profit
. . . . . . . . . . . . . . . . . . . .>     ) s AS campo, valor
. . . . . . . . . . . . . . . . . . . .> )
. . . . . . . . . . . . . . . . . . . .> SELECT
. . . . . . . . . . . . . . . . . . . .>     campo,
. . . . . . . . . . . . . . . . . . . .>     SUM(CASE WHEN valor IS NULL THEN 1 ELSE 0 END) AS cantidad_null,
. . . . . . . . . . . . . . . . . . . .>     SUM(CASE WHEN TRIM(valor) = '' THEN 1 ELSE 0 END) AS cantidad_vacios
. . . . . . . . . . . . . . . . . . . .> FROM campos
. . . . . . . . . . . . . . . . . . . .> GROUP BY campo
. . . . . . . . . . . . . . . . . . . .> HAVING SUM(
. . . . . . . . . . . . . . . . . . . .>     CASE WHEN valor IS NULL OR TRIM(valor) = '' THEN 1 ELSE 0 END
. . . . . . . . . . . . . . . . . . . .> ) > 0;
WARNING: Hive-on-MR is deprecated in Hive 2 and may not be available in the future versions. Consider using a different execution engine (i.e. spark, tez) or using Hive 1.X releases.
+--------+----------------+------------------+
| campo  | cantidad_null  | cantidad_vacios  |
+--------+----------------+------------------+
+--------+----------------+------------------+
No rows selected (1.272 seconds)

///Registros con fechas inválidas o inconsistentes.

0: jdbc:hive2://localhost:10000/default> SELECT
. . . . . . . . . . . . . . . . . . . .>     row_id, order_id, order_date, ship_date,
. . . . . . . . . . . . . . . . . . . .>     pedido_invalido, envio_invalido
. . . . . . . . . . . . . . . . . . . .> FROM auditoria_superstore
. . . . . . . . . . . . . . . . . . . .> WHERE pedido_invalido = 1
. . . . . . . . . . . . . . . . . . . .>    OR envio_invalido = 1
. . . . . . . . . . . . . . . . . . . .>    OR fecha_envio < fecha_pedido;
+---------+-----------+-------------+------------+------------------+-----------------+
| row_id  | order_id  | order_date  | ship_date  | pedido_invalido  | envio_invalido  |
+---------+-----------+-------------+------------+------------------+-----------------+
+---------+-----------+-------------+------------+------------------+-----------------+
No rows selected (0.238 seconds)
0: jdbc:hive2://localhost:10000/default> 

///Registros con ventas iguales o inferiores a cero.

0: jdbc:hive2://localhost:10000/default> SELECT row_id, order_id, product_name, sales_num
. . . . . . . . . . . . . . . . . . . .> FROM auditoria_superstore
. . . . . . . . . . . . . . . . . . . .> WHERE sales_num <= 0;
+---------+-----------+---------------+------------+
| row_id  | order_id  | product_name  | sales_num  |
+---------+-----------+---------------+------------+
+---------+-----------+---------------+------------+
No rows selected (0.152 seconds)

///Registros con descuentos fuera del intervalo esperado.

0: jdbc:hive2://localhost:10000/default> SELECT row_id, order_id, discount_num
. . . . . . . . . . . . . . . . . . . .> FROM auditoria_superstore
. . . . . . . . . . . . . . . . . . . .> WHERE discount_num < 0 OR discount_num > 1;
+---------+-----------+---------------+
| row_id  | order_id  | discount_num  |
+---------+-----------+---------------+
+---------+-----------+---------------+
No rows selected (0.184 seconds)
0: jdbc:hive2://localhost:10000/default> 

//Registros donde la fecha de envío sea anterior a la fecha de pedido.

0: jdbc:hive2://localhost:10000/default> SELECT
. . . . . . . . . . . . . . . . . . . .>     row_id, order_id, fecha_pedido, fecha_envio
. . . . . . . . . . . . . . . . . . . .> FROM auditoria_superstore
. . . . . . . . . . . . . . . . . . . .> WHERE pedido_invalido = 0
. . . . . . . . . . . . . . . . . . . .>   AND envio_invalido = 0
. . . . . . . . . . . . . . . . . . . .>   AND fecha_envio < fecha_pedido;
+---------+-----------+---------------+--------------+
| row_id  | order_id  | fecha_pedido  | fecha_envio  |
+---------+-----------+---------------+--------------+
+---------+-----------+---------------+--------------+
No rows selected (0.226 seconds)
0: jdbc:hive2://localhost:10000/default> 
