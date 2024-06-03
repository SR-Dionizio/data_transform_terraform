# Glue Database
resource "aws_glue_catalog_database" "datalake_database" {
  name = "schema-datalake-dados-dionizio"
}

# Glue Crawler
resource "aws_glue_crawler" "json_crawler" {
  name          = "datalake-dionizio-crawler"
  role          = aws_iam_role.lambda_exec_role.arn
  database_name = aws_glue_catalog_database.datalake_database.name

  s3_target {
    path = "s3://${aws_s3_bucket.datalake.bucket}/posts.json"
  }

  schema_change_policy {
    delete_behavior = "DEPRECATE_IN_DATABASE"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  configuration = jsonencode({
    "Version" : 1.0,
    "CrawlerOutput" : {
      "Partitions" : {
        "AddOrUpdateBehavior" : "InheritFromTable"
      }
    }
  })
}
# Glue Job
resource "aws_glue_job" "datalake_processing_job" {
  name     = "datalake-dionizio-processing-job"
  role_arn = aws_iam_role.lambda_exec_role.arn
  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.processing-job-py.bucket}/scripts/etl_script.py"
    python_version  = "3"
  }
  default_arguments = {
    "--job-language" = "python"
  }
  max_retries  = 1
  glue_version = "2.0"
}