resource "aws_s3_bucket" "datalake" {
  bucket = "datalake-dados-dionizio"

  tags = {
    Name        = "datalake"
    Environment = "Dev"
    Managedby   = "Terraform"
  }
}

resource "aws_s3_bucket" "processing-job-py" {
  bucket = "datalake-dados-dionizio-processing-job-py"
  tags = {
    Name        = "datalake"
    Environment = "Dev"
    Managedby   = "Terraform"
  }
}

# Upload do Script para o S3
resource "null_resource" "upload_spark_script" {
  provisioner "local-exec" {
    command = "aws s3 cp app/spark/transformed_data.py s3://${aws_s3_bucket.processing-job-py.bucket}/scripts/transformed_data.py"
  }
}