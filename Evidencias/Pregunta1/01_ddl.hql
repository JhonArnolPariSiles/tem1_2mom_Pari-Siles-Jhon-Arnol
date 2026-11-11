-- PREGUNTA 1: MODELADO Y CARGA

-- 1. Crear la base de datos
CREATE DATABASE IF NOT EXISTS superstore;
USE superstore;

-- 2. Crear la tabla externa de datos originales
CREATE EXTERNAL TABLE IF NOT EXISTS superstore_raw (
    row_id STRING,
    order_id STRING,
    order_date STRING,
    ship_date STRING,
    ship_mode STRING,
    customer_id STRING,
    customer_name STRING,
    segment STRING,
    country STRING,
    city STRING,
    state STRING,
    postal_code STRING,
    region STRING,
    product_id STRING,
    category STRING,
    sub_category STRING,
    product_name STRING,
    sales STRING,
    quantity STRING,
    discount STRING,
    profit STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
    "separatorChar" = ",",
    "quoteChar" = "\"",
    "escapeChar" = "\\"
)
STORED AS TEXTFILE
LOCATION '/data/superstore/raw'
TBLPROPERTIES ("skip.header.line.count" = "1");

-- 3. Crear la tabla analítica
CREATE TABLE IF NOT EXISTS superstore_analitica (
    row_id INT,
    order_id STRING,
    order_date DATE,
    ship_date DATE,
    ship_mode STRING,
    customer_id STRING,
    customer_name STRING,
    segment STRING,
    country STRING,
    city STRING,
    state STRING,
    postal_code STRING,
    region STRING,
    product_id STRING,
    category STRING,
    sub_category STRING,
    product_name STRING,
    sales DECIMAL(18,4),
    quantity INT,
    discount DECIMAL(5,4),
    profit DECIMAL(18,4)
)
STORED AS ORC
TBLPROPERTIES ("orc.compress" = "SNAPPY");

-- 4. Transformar y cargar los datos
INSERT OVERWRITE TABLE superstore_analitica
SELECT
    CAST(TRIM(row_id) AS INT),
    TRIM(order_id),
    CAST(
        FROM_UNIXTIME(
            UNIX_TIMESTAMP(TRIM(order_date), 'M/d/yyyy')
        ) AS DATE
    ),
    CAST(
        FROM_UNIXTIME(
            UNIX_TIMESTAMP(TRIM(ship_date), 'M/d/yyyy')
        ) AS DATE
    ),
    TRIM(ship_mode),
    TRIM(customer_id),
    TRIM(customer_name),
    TRIM(segment),
    TRIM(country),
    TRIM(city),
    TRIM(state),
    TRIM(postal_code),
    TRIM(region),
    TRIM(product_id),
    TRIM(category),
    TRIM(sub_category),
    TRIM(product_name),
    CAST(TRIM(sales) AS DECIMAL(18,4)),
    CAST(TRIM(quantity) AS INT),
    CAST(TRIM(discount) AS DECIMAL(5,4)),
    CAST(TRIM(profit) AS DECIMAL(18,4))
FROM superstore_raw;

-- 5. Mostrar campos y tipos
DESCRIBE superstore_raw;
DESCRIBE superstore_analitica;

-- 6. Mostrar el DDL
SHOW CREATE TABLE superstore_raw;
SHOW CREATE TABLE superstore_analitica;

-- 7. Verificar los registros importados
SELECT COUNT(*) AS registros_originales
FROM superstore_raw;

SELECT COUNT(*) AS registros_analiticos
FROM superstore_analitica;

-- 8. Mostrar una muestra de los datos
SELECT *
FROM superstore_analitica
LIMIT 10;

-- 9. Verificar formato y ubicación
DESCRIBE FORMATTED superstore_analitica;


docker compose up -d

docker exec superstore-namenode hdfs dfs -mkdir -p /data/superstore/raw

docker exec superstore-namenode hdfs dfs -put -f /data/superstore.csv /data/superstore/raw/

docker exec superstore-namenode hdfs dfs -ls /data/superstore/raw