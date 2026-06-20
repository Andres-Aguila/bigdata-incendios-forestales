Pipeline de Big Data — Predicción de Incendios Forestales en EE.UU.

Alumno: Victor Andres Aguila Lopez 
Materia: Big Data
Institución: UPIIT-IPN Campus Tlaxcala

- Descripción

Pipeline completo de Big Data para el procesamiento, análisis exploratorio y modelado predictivo de "1,880,465 registros históricos" de incendios forestales en EE.UU. (1992–2015), implementado sobre el ecosistema Hadoop con HDFS, Apache Hive, Apache Pig y Spark MLlib.

- Arquitectura

[Kaggle API] → [Python/pandas] → [HDFS] → [Hive / Pig] → [Spark MLlib] → [matplotlib]
 Descarga       SQLite→CSV       Almacén   EDA + MapReduce   Regresión     Visualización

- Estructura del Repositorio

bigdata-incendios/
├── data/
│   └── wildfires.csv          # Dataset exportado (153 MB, 1.88M registros)
├── ingesta/
│   └── 01_subir_hdfs.sh       # Script para subir datos a HDFS
├── hive/
│   └── 02_crear_tabla.hql      # Tabla externa + 4 queries de EDA
├── pig/
│   └── 03_analisis_pig.pig    # Agregaciones MapReduce con Pig
├── spark/
│   └── 04_modelo_sparkml.py   # Modelo Random Forest con Spark MLlib
├── visualizacion/
│   ├── grafica_1_causas.png
│   ├── grafica_2_por_anio.png
│   ├── grafica_3_estados.png
│   └── grafica_4_clases.png
├── Pipeline_Incendios_Forestales.ipynb      # Exploración y exportación del dataset
├── Visualizacion.ipynb                      # Generación de gráficas con matplotlib
└── README.md

- Dataset

| Campo | Valor |
|---|---|
| Nombre | 1.88 Million US Wildfires |
| Fuente | [Kaggle](https://www.kaggle.com/datasets/rtatman/188-million-us-wildfires) |
| Licencia | CC0-1.0 (dominio público) |
| Registros | 1,880,465 |
| Periodo | 1992–2015 |
| Formato original | SQLite (795 MB) |
| Formato procesado | CSV (153 MB) |
| Columnas usadas | 12 de 38 |

- Descargar con Kaggle CLI:
kaggle datasets download -d rtatman/188-million-us-wildfires


- Entorno de Desarrollo

| Componente | Versión |
|---|---|
| Ubuntu | 24.04.4 LTS |
| Java (OpenJDK) | 1.8.0_492 |
| Apache Hadoop | 3.4.0 |
| Apache Hive | 4.0.0 |
| Apache Pig | 0.17.0 |
| Apache Spark | 3.x (Docker: apache/spark-py) |
| Docker | 29.4.2 |
| Python | 3.10.20 |
| pandas | 2.3.3 |
| matplotlib | 3.10.9 |
| kaggle CLI | 1.7.4.5 |

- Instrucciones de Ejecución

- Requisitos previos

1 - Activar entorno conda
conda activate bigdata_incendios

2 - Iniciar Hadoop
start-dfs.sh && start-yarn.sh

3 - Verificar que los 5 procesos estén activos
jps
Debe mostrar: NameNode, DataNode, SecondaryNameNode, ResourceManager, NodeManager


- Ingesta — Subir dataset a HDFS

bash ingesta/01_subir_hdfs.sh

hdfs dfs -mkdir -p /user/vaal/bigdata_incendios/raw
hdfs dfs -put data/wildfires.csv /user/vaal/bigdata_incendios/raw/
hdfs dfs -ls -h /user/vaal/bigdata_incendios/raw/

- Exploración del dataset 

Abrir `Pipeline_Incendios_Forestales.ipynb`


- Hive — Tabla externa y análisis exploratorio

Levantar HiveServer2

cd /usr/local/hive
hive --service hiveserver2 &
sleep 30

Conectar con Beeline y ejecutar el script
beeline -u jdbc:hive2://localhost:10000 -n vaal -f hive/02_crear_tabla.hql

- Pig — Análisis complementario MapReduce

pig -x mapreduce pig/03_analisis_pig.pig 2>/dev/null

Verificar resultados en HDFS:
hdfs dfs -cat /user/vaal/bigdata_incendios/pig_output/por_propietario/part-r-00000
hdfs dfs -cat /user/vaal/bigdata_incendios/pig_output/por_clase/part-r-00000


- Spark MLlib — Modelo predictivo

Copiar dataset al contenedor Docker:
docker cp data/wildfires.csv dazzling_mendeleev:/tmp/wildfires.csv
docker cp spark/04_modelo_sparkml.py dazzling_mendeleev:/tmp/04_modelo_sparkml.py

Ejecutar el modelo:
docker exec -it dazzling_mendeleev \
  /opt/spark/bin/spark-submit /tmp/04_modelo_sparkml.py 2>/dev/null

- Visualización (Jupyter)

Abrir `Visualizacion.ipynb`

- Resultados del Modelo

| Métrica | Valor | Interpretación |
|---|---|---|
| RMSE | 2,303.69 acres | Influenciado por incendios extremos clase G |
| R² | 0.2896 | El modelo explica el 29% de la varianza |
| MAE | 64.47 acres | Error promedio absoluto en predicción |

Algoritmo: Random Forest Regressor 
Configuración: 50 árboles · profundidad 6 · maxBins=64 
Split: 80% entrenamiento (1,504,515) / 20% prueba (375,950) · seed=42 

-  Hallazgos Principales

- Causa más frecuente: Debris Burning con 429,028 casos (22.8% del total)
- Estado con más incendios: California con 189,550 eventos
- Año más activo: 2006 con 114,004 incendios registrados
- Mayor riesgo: Clase G (≥5,000 acres) con promedio de 27,388 acres por evento
- 85% de los incendios son clase A o B (menos de 10 acres)
- Mayor magnitud en tierras federales: FWS con 996 acres promedio por incendio


- Licencia del Dataset

Este proyecto utiliza datos del dominio público bajo licencia CC0-1.0. 
Fuente: Short, K.C. (2017). *1.88 Million US Wildfires*. USDA Forest Service / Kaggle.
