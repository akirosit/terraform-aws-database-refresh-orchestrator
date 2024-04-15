# Description: This file contains the IAM roles for the Lambda and Step Function

#
# Lambda IAM Role
#
resource "aws_iam_role" "lambda" {
  name               = "${local.name_cc}Lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_from_lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda.name
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.lambda.name
}

resource "aws_iam_policy" "lambda_role" {
  name   = "${local.name_cc}Lambda"
  policy = data.aws_iam_policy_document.lambda_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_role" {
  policy_arn = aws_iam_policy.lambda_role.arn
  role       = aws_iam_role.lambda.name
}

resource "aws_iam_role_policy_attachment" "lambda_s3" {
  policy_arn = aws_iam_policy.s3.arn
  role       = aws_iam_role.lambda.name
}

#
# Step Function IAM Role
#
resource "aws_iam_role" "step_function" {
  name               = "${local.name_cc}StepFunction"
  assume_role_policy = data.aws_iam_policy_document.assume_from_step_functions.json
}

resource "aws_iam_policy" "step_function_role" {
  name   = "${local.name_cc}StepFunction"
  path   = "/"
  policy = data.aws_iam_policy_document.step_function_role.json
}

resource "aws_iam_role_policy_attachment" "step_function_role" {
  policy_arn = aws_iam_policy.step_function_role.arn
  role       = aws_iam_role.step_function.name
}

resource "aws_iam_role_policy_attachment" "step_function_s3" {
  policy_arn = aws_iam_policy.s3.arn
  role       = aws_iam_role.step_function.name
}

#
# RDS IAM Role
#
resource "aws_iam_role" "rds" {
  name               = "${local.name_cc}Rds"
  assume_role_policy = data.aws_iam_policy_document.assume_from_rds.json
}
resource "aws_iam_policy" "s3" {
  name   = "${local.name_cc}S3"
  policy = data.aws_iam_policy_document.s3.json
}
resource "aws_iam_role_policy_attachment" "rds_s3" {
  policy_arn = aws_iam_policy.s3.arn
  role       = aws_iam_role.rds.name
}