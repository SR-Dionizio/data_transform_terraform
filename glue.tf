
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
    "--job-language"    = "python"
    "--RedshiftTempDir" = "s3://${aws_s3_bucket.processing-job-py.bucket}/temp/"
    "--TempDir"         = "s3://${aws_s3_bucket.processing-job-py.bucket}/temp/"
  }
  max_retries  = 1
  glue_version = "2.0"
}
