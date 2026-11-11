# Análisis de Superstore con Hive y Docker

**Autor:** Jhon Arnol Pari Siles  
**Examen Práctico Individual — Segundo Momento**

## Descripción

Proyecto de análisis de ventas del dataset Superstore utilizando Apache Hive, HDFS y Docker. Contiene 9.994 registros, 5.009 órdenes y 793 clientes.

## Objetivos

- Crear y cargar tablas en Hive.
- Verificar la calidad de los datos.
- Analizar ventas, ganancias, productos y clientes.
- Evaluar descuentos y tendencias temporales.
- Identificar la concentración de ventas y ganancias mediante Pareto.

## Requisitos

- Docker Desktop en ejecución con contenedores Linux.
- Docker Compose.
- Visual Studio Code.
- Dataset guardado en `data/superstore.csv`.

Dataset: [Superstore — Kaggle](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final)

## Estructura

```text
tem1_2mom_Pari-Siles-Jhon-Arnol/
├── data/
│   └── superstore.csv
├── Evidencias/
│   ├── Pregunta1/
│   │   └── 01_ddl.hql
│   ├── Pregunta2/
│   │   └── 02_auditoria.hql
│   ├── Pregunta3/
│   │   └── 03_Análisis_de_evolución_comercial_región.hql
│   ├── pregunta4/
│   │   └── 04_segmentacion.hql
│   ├── Pregunta5/
│   │   └── 05_RankingProductos.hql
│   ├── Pregunta6/
│   │   └── 06_Análisis_impacto_descuentos.hql
│   ├── Pregunta7/
│   │   └── 07_TendenciasTemporales.hql
│   └── Pregunta8/
│       ├── 08_A.hql
│       └── 08_B.hql
├── docker-compose.yml
├── hadoop-hive.env
└── README.md
```

## Procedimiento de ejecución

### 1. Iniciar los contenedores

Desde la terminal de VS Code, en la raíz del proyecto:

```powershell
docker compose up -d
docker compose ps
```

### 2. Cargar el CSV en HDFS

Cuando los servicios estén disponibles:

```powershell
docker exec superstore-namenode hdfs dfs -mkdir -p /data/superstore/raw
docker exec superstore-namenode hdfs dfs -put -f /data/superstore.csv /data/superstore/raw/
docker exec superstore-namenode hdfs dfs -ls /data/superstore/raw
```

### 3. Conectarse a Hive

```powershell
docker exec -it superstore-hive-server beeline -u "jdbc:hive2://localhost:10000/default" -n root
```

### 4. Ejecutar los archivos HQL

Copiar y pegar el contenido de los archivos en Beeline, siguiendo el orden de las preguntas:

1. Pregunta 1: crear la base, las tablas y ejecutar la carga.
2. Pregunta 2: auditoría de calidad.
3. Pregunta 3: evolución comercial por región.
4. Pregunta 4: segmentación RFM.
5. Pregunta 5: ranking de productos.
6. Pregunta 6: impacto de los descuentos.
7. Pregunta 7: tendencias temporales.
8. Pregunta 8: Pareto de ventas y ganancias.

Después de crear la base, seleccionar:

```sql
USE superstore;
```

El archivo de la pregunta 1 debe incluir el `INSERT OVERWRITE` que carga la tabla analítica.

### 5. Verificar los registros

```sql
SELECT COUNT(*) FROM superstore_raw;
SELECT COUNT(*) FROM superstore_analitica;
SELECT * FROM superstore_analitica LIMIT 5;
```

Ambas tablas deben contener 9.994 registros para el CSV utilizado.

### 6. Finalizar

Salir de Beeline:

```text
!quit
```

Detener los servicios desde PowerShell:

```powershell
docker compose stop
```

## Diccionario de datos

La tabla `superstore_raw` conserva todos los campos como STRING. La tabla `superstore_analitica` utiliza los siguientes tipos:

| Campo | Tipo Hive | Descripción y validación |
|---|---|---|
| row_id | INT | Identificador de fila; positivo y único |
| order_id | STRING | Identificador del pedido; obligatorio |
| order_date | DATE | Fecha del pedido; fecha válida |
| ship_date | DATE | Fecha de envío; no anterior al pedido |
| ship_mode | STRING | Modalidad de envío; no vacío |
| customer_id | STRING | Identificador del cliente; obligatorio |
| customer_name | STRING | Nombre del cliente; no vacío |
| segment | STRING | Segmento comercial; Consumer, Corporate o Home Office |
| country | STRING | País; no vacío |
| city | STRING | Ciudad; no vacío |
| state | STRING | Estado; no vacío |
| postal_code | STRING | Código postal; conserva ceros iniciales |
| region | STRING | Región; Central, East, South o West |
| product_id | STRING | Identificador del producto; obligatorio |
| category | STRING | Categoría; Furniture, Office Supplies o Technology |
| sub_category | STRING | Subcategoría del producto; no vacío |
| product_name | STRING | Nombre del producto; admite comas entre comillas |
| sales | DECIMAL(18,4) | Importe vendido; mayor que cero |
| quantity | INT | Unidades vendidas; entero positivo |
| discount | DECIMAL(5,4) | Descuento entre 0 y 1 |
| profit | DECIMAL(18,4) | Ganancia; admite pérdidas negativas |

Estas validaciones se comprueban mediante consultas; Hive no las aplica automáticamente.

Las fechas originales se convierten desde `M/d/yyyy`. La tabla analítica se almacena en ORC con compresión SNAPPY.

## Resultados principales

- No se detectaron inconsistencias en los controles de calidad realizados.
- West lideró las ganancias regionales en tres de los cuatro años.
- Todas las operaciones con descuentos superiores al 50 % generaron pérdidas.
- Noviembre de 2017 registró el mayor importe mensual de ventas.
- 414 productos concentran el 80,04 % de las ventas.
- 164 productos concentran el 80,03 % de la ganancia neta.

## Conclusión

El análisis permitió identificar clientes valiosos, productos rentables y períodos de mayor venta. Los resultados muestran que vender más no siempre implica ganar más y que los descuentos elevados están asociados con una mayor proporción de pérdidas.