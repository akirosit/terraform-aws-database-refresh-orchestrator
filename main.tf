locals {
  step_function_definition_file = var.use_jsonata_template ? "step_function_definition_jsonata.json" : "step_function_definition_jsonpath.json"
  lambdas_arn = { for lambda_name, lambda in aws_lambda_function.functions :
    lambda_name => lambda.arn
  }
}

resource "aws_sfn_state_machine" "refresh_env" {
  name       = local.name_cc
  role_arn   = aws_iam_role.step_function.arn
  definition = templatefile("${path.module}/templates/${local.step_function_definition_file}", local.lambdas_arn)
}