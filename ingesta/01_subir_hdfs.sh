#!/bin/bash
# Script de ingesta: crea estructura en HDFS y sube el dataset
# Proyecto: Pipeline Big Data - Incendios Forestales
# Autor: Victor Andres Aguila Lopez

echo "=== Creando estructura en HDFS ==="
hdfs dfs -mkdir -p /user/vaal/bigdata_incendios/raw

echo "=== Subiendo dataset a HDFS ==="
hdfs dfs -put data/wildfires.csv /user/vaal/bigdata_incendios/raw/

echo "=== Verificando carga ==="
hdfs dfs -ls -h /user/vaal/bigdata_incendios/raw/

echo "=== Ingesta completada ==="
