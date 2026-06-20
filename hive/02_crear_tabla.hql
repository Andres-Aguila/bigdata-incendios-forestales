-- Pipeline Big Data: Incendios Forestales
-- Autor: Victor Andres Aguila Lopez
-- Ejecutar con: beeline -u jdbc:hive2://localhost:10000 -n vaal -f 02_crear_tabla.hql

CREATE DATABASE IF NOT EXISTS incendios;
USE incendios;

CREATE EXTERNAL TABLE IF NOT EXISTS wildfires (
  FIRE_YEAR       INT,
  DISCOVERY_DATE  DOUBLE,
  DISCOVERY_DOY   INT,
  STAT_CAUSE_DESCR STRING,
  FIRE_SIZE       DOUBLE,
  FIRE_SIZE_CLASS STRING,
  LATITUDE        DOUBLE,
  LONGITUDE       DOUBLE,
  STATE           STRING,
  CONT_DATE       DOUBLE,
  CONT_DOY        DOUBLE,
  OWNER_DESCR     STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/vaal/bigdata_incendios/raw/'
TBLPROPERTIES ("skip.header.line.count"="1");

-- Query 1: Top 10 causas de incendio
SELECT STAT_CAUSE_DESCR, COUNT(*) AS total
FROM wildfires
GROUP BY STAT_CAUSE_DESCR
ORDER BY total DESC
LIMIT 10;

-- Query 2: Incendios por año
SELECT FIRE_YEAR, COUNT(*) AS total_incendios,
       ROUND(AVG(FIRE_SIZE), 4) AS promedio_acres
FROM wildfires
GROUP BY FIRE_YEAR
ORDER BY FIRE_YEAR ASC;

-- Query 3: Top 10 estados
SELECT STATE, COUNT(*) AS total,
       ROUND(AVG(FIRE_SIZE), 4) AS promedio_acres
FROM wildfires
GROUP BY STATE
ORDER BY total DESC
LIMIT 10;

-- Query 4: Distribucion por clase de tamanio
SELECT FIRE_SIZE_CLASS, COUNT(*) AS total,
       ROUND(AVG(FIRE_SIZE), 4) AS promedio_acres
FROM wildfires
GROUP BY FIRE_SIZE_CLASS
ORDER BY FIRE_SIZE_CLASS ASC;
