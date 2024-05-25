import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(sys.argv, ['DATALAKE_DIONIZIO'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Carregar os dados da tabela no Glue Data Catalog
datasource = glueContext.create_dynamic_frame.from_catalog(
    database="json_database",
    table_name="posts"
)

# Transformações de ETL (Exemplo: Filtrar dados)
transformed_data = Filter.apply(
    frame=datasource,
    f=lambda x: x["userId"] == 1
)

# Gravar os dados transformados de volta para o S3
glueContext.write_dynamic_frame.from_options(
    frame=transformed_data,
    connection_type="s3",
    connection_options={"path": "s3://<your-output-bucket>/output/"},
    format="json"
)

job.commit()
