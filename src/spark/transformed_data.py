import boto3
from awsglue.transforms import *
from botocore.exceptions import ClientError
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
import pyspark.sql.functions as F


args = {
    "JOB_NAME": "my_jupyter_job"
}

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

spark.sparkContext.setLogLevel("ERROR")

# Exemplo de leitura de um arquivo JSON no S3
df = spark.read.json("s3a://datalake-dados-dionizio/cars_pricing.json")
df.show()

df = spark.read.json("s3://datalake-dados-dionizio/cars_pricing.json")
df = df.withColumn("Preço", F.regexp_replace("Preço", "R\\$", ""))

output_path = "s3://datawarehouse-dados/cars_pricing_parquet/"

df.write.mode("overwrite").parquet(output_path)
