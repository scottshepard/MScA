from pyspark.sql.functions import lit
from pyspark.sql import SparkSession
from pyspark.ml import Pipeline
from pyspark.ml.classification import LogisticRegression
from pyspark.ml.evaluation import MulticlassClassificationEvaluator
from pyspark.ml.image import ImageSchema

from sparkdl.image import imageIO
from sparkdl import DeepImageFeaturizer

#!pip install sparkdl
#!pip install tensorflow
#!pip install keras
#!pip install kafka-python
#!pip install tensorflowonspark

# create Spark session
# spark = SparkSession.builder.appName('SparkDeepLearning').getOrCreate()

# change configuration settings on Spark
# conf = spark.sparkContext._conf.setAll([('spark.executor.memory', '4g'), ('spark.app.name', 'Spark Updated Conf'), (
#    'spark.executor.cores', '4'), ('spark.cores.max', '4'), ('spark.driver.memory', '8g')])

imageDir = "T://courses//BigData//data//flower_photos"

# Load images
# image_df = ImageSchema.readImages(imageDir, recursive = True).withColumn("label", lit(1))
# image_df.printSchema()
# image_df.show(5)
# train_df, test_df, _=image_df.randomSplit([0.1, 0.05, 0.85])

# read images using two methods
tulips_df = ImageSchema.readImages(imageDir
                                   + "/tulips").withColumn("label", lit(1))
daisy_df = imageIO.readImagesWithCustomFn(imageDir
                                          + "/daisy", decode_f=imageIO.PIL_decode).withColumn("label", lit(0))

# use larger training sets (e.g. [0.6, 0.4] for getting more images)
tulips_train, tulips_test, _ = tulips_df.randomSplit([0.1, 0.05, 0.85])
# use larger training sets (e.g. [0.6, 0.4] for getting more images)
daisy_train, daisy_test, _ = daisy_df.randomSplit([0.1, 0.05, 0.85])

train_df = tulips_train.unionAll(daisy_train)
test_df = tulips_test.unionAll(daisy_test)

# Under the hood, each of the partitions is fully loaded in memory, which may be expensive.
# This ensure that each of the paritions has a small size.
train_df = train_df.repartition(100)
test_df = test_df.repartition(100)

# create Deep Image Featurizer
featurizer = DeepImageFeaturizer(
    inputCol="image", outputCol="features", modelName="InceptionV3")
lr = LogisticRegression(maxIter=20, regParam=0.05,
                        elasticNetParam=0.3, labelCol="label")
p = Pipeline(stages=[featurizer, lr])

# train_images_df is a dataset of images and labels
model = p.fit(train_df)

# Inspect training error
trained_df = model.transform(train_df.limit(10)).select(
    "image", "probability",  "prediction", "label")

predictions = trained_df.select("prediction", "label")
evaluator = MulticlassClassificationEvaluator(metricName="accuracy")
print("Training set accuracy = " + str(evaluator.evaluate(predictions)))

# Run model against the test dataset
tested_df = model.transform(train_df.limit(10)).select(
    "image", "probability",  "prediction", "label")

predictions = tested_df.select("prediction", "label")

# Evaluate our model
evaluator = MulticlassClassificationEvaluator(metricName="accuracy")
print("Test set accuracy = " + str(evaluator.evaluate(predictions)))
