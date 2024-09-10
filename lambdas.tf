# Description: This file contains the code to create the lambda functions

locals {
  python_version_short = "3.9"
  python_version_long  = "python${local.python_version_short}"
  lambda_layers = [
    "pymysql",
    "cryptography"
  ]
  lambda_functions = {
    "awssoldb-RunScriptsMySQL" = {
      type    = "file"
      path    = "${local.lambdas_path}/awssoldb-RunScriptsMySQL.py"
      timeout = 900
    }
    "SecretsManagerRDSMySQLRotationMultiUser" = {
      type       = "github_file"
      repository = "aws-samples/aws-secrets-manager-rotation-lambdas"
      branch     = "master"
      path       = "SecretsManagerRDSMySQLRotationMultiUser/lambda_function.py"
      permissions = {
        "AllowExecutionFromSecretsManager" = {
          action    = "lambda:InvokeFunction"
          principal = "secretsmanager.amazonaws.com"
        }
      }
      environment = {
        "variables" = {
          EXCLUDE_CHARACTERS         = var.rotate_database_exclude_characters
          EXCLUDE_LOWERCASE          = false
          EXCLUDE_NUMBERS            = false
          EXCLUDE_PUNCTUATION        = false
          EXCLUDE_UPPERCASE          = false
          PASSWORD_LENGTH            = 32
          REQUIRE_EACH_INCLUDED_TYPE = true
          SECRETS_MANAGER_ENDPOINT   = "https://secretsmanager.${local.current_region}.amazonaws.com"
          USERNAME_CHARACTER_LIMIT   = 32
        }
      }
    }
  }
  lambda_functions_layers = {
    "awssoldb-RunScriptsMySQL" = [aws_lambda_layer_version.layer["pymysql"].arn]
    "SecretsManagerRDSMySQLRotationMultiUser" = [
      aws_lambda_layer_version.layer["pymysql"].arn,
      aws_lambda_layer_version.layer["cryptography"].arn
    ]
  }
  lambda_functions_allow_from_externals = flatten([
    for lambda_name, lambda in local.lambda_functions : [
      for permission_name, permission in lookup(lambda, "permissions", {}) : {
        name          = permission_name
        function_name = aws_lambda_function.functions[lambda_name].function_name
        action        = permission.action
        principal     = permission.principal
      }
  ]])
}

resource "aws_lambda_layer_version" "layer" {
  for_each                 = data.archive_file.lambda_layers
  layer_name               = "${var.app_name}-${var.env_name}-${each.key}"
  filename                 = each.value.output_path
  source_code_hash         = each.value.output_base64sha256
  compatible_runtimes      = [local.python_version_long]
  compatible_architectures = ["arm64"]
}

resource "aws_lambda_function" "functions" {
  for_each         = aws_s3_object.lambda_functions
  function_name    = "${each.key}-${var.app_name}-${var.env_name}"
  role             = aws_iam_role.lambda.arn
  s3_bucket        = each.value.bucket
  s3_key           = each.value.key
  source_code_hash = aws_s3_object.lambda_functions_hash[each.key].content
  handler          = "${each.key}.lambda_handler"
  runtime          = local.python_version_long
  architectures    = ["arm64"]
  layers           = lookup(local.lambda_functions_layers, each.key, [])
  timeout          = lookup(local.lambda_functions[each.key], "timeout", 300)
  memory_size      = 320
  vpc_config {
    security_group_ids = [
      aws_security_group.lambda.id
    ]
    subnet_ids = var.private_subnets_ids
  }
  dynamic "environment" {
    for_each = lookup(local.lambda_functions[each.key], "environment", {})
    content {
      variables = environment.value
    }
  }
}

resource "aws_lambda_permission" "allow_secrets_manager" {
  for_each = {
    for permission in local.lambda_functions_allow_from_externals : permission.name => permission
  }
  statement_id  = each.key
  action        = each.value.action
  function_name = each.value.function_name
  principal     = each.value.principal
}