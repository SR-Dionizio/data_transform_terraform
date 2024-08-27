
# Glue Job
resource "aws_glue_job" "datalake_processing_job" {
  name     = "datalake-dionizio-processing-job"
  role_arn = aws_iam_role.lambda_exec_role.arn
  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.processing-job-py.bucket}/scripts/transformed_data.py"
    python_version  = "3"
  }
  default_arguments = {
    "--job-language"    = "python"
  }
  max_retries  = 1
  glue_version = "3.0"
}
