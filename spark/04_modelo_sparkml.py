from pyspark.sql import SparkSession
from pyspark.sql.functions import col
from pyspark.ml.feature import StringIndexer, VectorAssembler
from pyspark.ml.regression import RandomForestRegressor
from pyspark.ml.evaluation import RegressionEvaluator
from pyspark.ml import Pipeline

spark = SparkSession.builder.appName("IncendiosForestales_ML").getOrCreate()
spark.sparkContext.setLogLevel("ERROR")

print("=== Cargando dataset ===")
df = spark.read.csv("/tmp/wildfires.csv", header=True, inferSchema=True)
print(f"Total registros: {df.count()}")

print("=== Preprocesamiento ===")
df_clean = df.dropna(subset=["FIRE_SIZE","LATITUDE","LONGITUDE","FIRE_YEAR","STAT_CAUSE_DESCR","FIRE_SIZE_CLASS","STATE"])
df_clean = df_clean.filter(col("FIRE_SIZE") > 0)
print(f"Registros tras limpieza: {df_clean.count()}")

cause_indexer = StringIndexer(inputCol="STAT_CAUSE_DESCR", outputCol="cause_idx", handleInvalid="keep")
state_indexer = StringIndexer(inputCol="STATE", outputCol="state_idx", handleInvalid="keep")
class_indexer = StringIndexer(inputCol="FIRE_SIZE_CLASS", outputCol="class_idx", handleInvalid="keep")

assembler = VectorAssembler(
    inputCols=["FIRE_YEAR","DISCOVERY_DOY","LATITUDE","LONGITUDE","cause_idx","state_idx","class_idx"],
    outputCol="features"
)

rf = RandomForestRegressor(featuresCol="features", labelCol="FIRE_SIZE", numTrees=50, maxDepth=6, maxBins=64, seed=42)
pipeline = Pipeline(stages=[cause_indexer, state_indexer, class_indexer, assembler, rf])

print("=== Dividiendo datos train/test 80/20 ===")
train, test = df_clean.randomSplit([0.8, 0.2], seed=42)
print(f"Train: {train.count()} | Test: {test.count()}")

print("=== Entrenando modelo ===")
model = pipeline.fit(train)

print("=== Evaluando modelo ===")
predictions = model.transform(test)

rmse = RegressionEvaluator(labelCol="FIRE_SIZE", predictionCol="prediction", metricName="rmse").evaluate(predictions)
r2   = RegressionEvaluator(labelCol="FIRE_SIZE", predictionCol="prediction", metricName="r2").evaluate(predictions)
mae  = RegressionEvaluator(labelCol="FIRE_SIZE", predictionCol="prediction", metricName="mae").evaluate(predictions)

print("=== METRICAS DEL MODELO ===")
print(f"RMSE : {rmse:.4f}")
print(f"R2   : {r2:.4f}")
print(f"MAE  : {mae:.4f}")

predictions.select("FIRE_YEAR","STATE","STAT_CAUSE_DESCR","FIRE_SIZE","prediction") \
           .write.csv("/tmp/predicciones_output", header=True, mode="overwrite")

print("=== PROCESO COMPLETADO ===")
spark.stop()
