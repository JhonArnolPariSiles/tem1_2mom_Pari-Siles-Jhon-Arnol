0: jdbc:hive2://localhost:10000/default> SHOW CREATE TABLE superstore_raw;
+----------------------------------------------------+
|                   createtab_stmt                   |
+----------------------------------------------------+
| CREATE EXTERNAL TABLE `superstore_raw`(            |
|   `row_id` string COMMENT 'from deserializer',     |
|   `order_id` string COMMENT 'from deserializer',   |
|   `order_date` string COMMENT 'from deserializer',  |
|   `ship_date` string COMMENT 'from deserializer',  |
|   `ship_mode` string COMMENT 'from deserializer',  |
|   `customer_id` string COMMENT 'from deserializer',  |
|   `customer_name` string COMMENT 'from deserializer',  |
|   `segment` string COMMENT 'from deserializer',    |
|   `country` string COMMENT 'from deserializer',    |
|   `city` string COMMENT 'from deserializer',       |
|   `state` string COMMENT 'from deserializer',      |
|   `postal_code` string COMMENT 'from deserializer',  |
|   `region` string COMMENT 'from deserializer',     |
|   `product_id` string COMMENT 'from deserializer',  |
|   `category` string COMMENT 'from deserializer',   |
|   `sub_category` string COMMENT 'from deserializer',  |
|   `product_name` string COMMENT 'from deserializer',  |
|   `sales` string COMMENT 'from deserializer',      |
|   `quantity` string COMMENT 'from deserializer',   |
|   `discount` string COMMENT 'from deserializer',   |
|   `profit` string COMMENT 'from deserializer')     |
| ROW FORMAT SERDE                                   |
|   'org.apache.hadoop.hive.serde2.OpenCSVSerde'     |
| WITH SERDEPROPERTIES (                             |
|   'escapeChar'='\\',                               |
|   'quoteChar'='"',                                 |
|   'separatorChar'=',')                             |
| STORED AS INPUTFORMAT                              |
|   'org.apache.hadoop.mapred.TextInputFormat'       |
| OUTPUTFORMAT                                       |
|   'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat' |
| LOCATION                                           |
|   'hdfs://namenode:8020/data/superstore/raw'       |
| TBLPROPERTIES (                                    |
|   'skip.header.line.count'='1',                    |
|   'transient_lastDdlTime'='1794410736')            |
+----------------------------------------------------+
37 rows selected (0.081 seconds)
0: jdbc:hive2://localhost:10000/default> SHOW CREATE TABLE superstore_analitica;
+----------------------------------------------------+
|                   createtab_stmt                   |
+----------------------------------------------------+
| CREATE TABLE `superstore_analitica`(               |
|   `row_id` int,                                    |
|   `order_id` string,                               |
|   `order_date` date,                               |
|   `ship_date` date,                                |
|   `ship_mode` string,                              |
|   `customer_id` string,                            |
|   `customer_name` string,                          |
|   `segment` string,                                |
|   `country` string,                                |
|   `city` string,                                   |
|   `state` string,                                  |
|   `postal_code` string,                            |
|   `region` string,                                 |
|   `product_id` string,                             |
|   `category` string,                               |
|   `sub_category` string,                           |
|   `product_name` string,                           |
|   `sales` decimal(18,4),                           |
|   `quantity` int,                                  |
|   `discount` decimal(5,4),                         |
|   `profit` decimal(18,4))                          |
| ROW FORMAT SERDE                                   |
|   'org.apache.hadoop.hive.ql.io.orc.OrcSerde'      |
| STORED AS INPUTFORMAT                              |
|   'org.apache.hadoop.hive.ql.io.orc.OrcInputFormat'  |
| OUTPUTFORMAT                                       |
|   'org.apache.hadoop.hive.ql.io.orc.OrcOutputFormat' |
| LOCATION                                           |
|   'hdfs://namenode:8020/user/hive/warehouse/superstore.db/superstore_analitica' |
| TBLPROPERTIES (                                    |
|   'orc.compress'='SNAPPY',                         |
|   'transient_lastDdlTime'='1794410863')            |
+----------------------------------------------------+
33 rows selected (0.038 seconds)
0: jdbc:hive2://localhost:10000/default> 