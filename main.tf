locals {
  # Seules les ressources nécessaires pour la step function sont conservées
  lambdas_arn = { for lambda_name, lambda in aws_lambda_function.functions :
    lambda_name => lambda.arn
  }
}

resource "aws_sfn_state_machine" "refresh_env" {
  name       = local.name_cc
  role_arn   = aws_iam_role.step_function.arn
  definition = templatefile("${path.module}/templates/step_function_definition.json", local.lambdas_arn)
}