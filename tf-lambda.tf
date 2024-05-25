#define variables
locals {
  layer_path        = "${path.module}/app/lambda/"
  layer_zip_name    = "request_posts.zip"
  requirements_name = "requirements.txt"
  requirements_path = "${path.module}/${local.layer_path}/${local.requirements_name}"
  layer_zip_path    = "${path.module}/${local.layer_path}/${local.layer_zip_name}"
}

# create zip file from requirements.txt. Triggers only when the file is updated
resource "null_resource" "lambda_layer" {
  triggers = {
    requirements = filesha1(local.requirements_path)
  }
  # the command to install python and dependencies to the machine and zips
  provisioner "local-exec" {
    command = <<EOT
      cd ${local.layer_path}
      rm -rf python
      mkdir python
      pip3 install -r ${local.requirements_name} -t python
      zip -r ${local.layer_zip_name} python
      echo "Created zip file at ${local.layer_zip_path}"
    EOT
  }
}

resource "aws_lambda_function" "hook-datalake" {
  function_name = "hook-datalake-dados-dionizio"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "request_posts.lambda_handler"
  runtime       = "python3.11"
  depends_on    = [null_resource.lambda_layer]
  filename      = local.layer_zip_path
}

