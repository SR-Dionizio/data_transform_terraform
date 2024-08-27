# IAM Role and Policies for Lambda and Glue
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = [
            "lambda.amazonaws.com",
            "glue.amazonaws.com"
          ]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "glue_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "s3_access" {
  name = "lambda_glue_s3_access_policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "s3:*",
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::datalake-dados-dionizio",
          "arn:aws:s3:::datalake-dados-dionizio/*",
          "arn:aws:s3:::datalake-dados-dionizio-processing-job-py",
          "arn:aws:s3:::datalake-dados-dionizio-processing-job-py/*",
          "arn:aws:s3:::datawarehouse-dados",
          "arn:aws:s3:::datawarehouse-dados/*"
        ]
      },
      {
        Action = [
          "glue:*",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}
