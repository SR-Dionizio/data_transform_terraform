import boto3
from awsglue.transforms import *
from botocore.exceptions import ClientError
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
import pyspark.sql.functions as F


class CarPricing:
    def __init__(self):
        self.spark = self._create_job()

    def read_data(self, file_path="s3a://datalake-dados-dionizio/cars_pricing.json"):
        df = self.spark.read.json(file_path)
        df = df.withColumn("Preço", F.regexp_replace("Preço", "R\\$", ""))
        return df

    @staticmethod
    def _create_job():
        args = {
            "JOB_NAME": "my_jupyter_job"
        }

        sc = SparkContext()
        glueContext = GlueContext(sc)
        spark = glueContext.spark_session
        job = Job(glueContext)
        job.init(args["JOB_NAME"], args)

        return spark

    def write_data(self, df, output_path="s3://datawarehouse-dados/cars_pricing_parquet/"):
        df.write.mode("overwrite").parquet(output_path)


if __name__ == "__main__":
    data = CarPricing()
    df = data.read_data()
    data.write_data(df)
