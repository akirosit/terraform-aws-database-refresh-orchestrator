# Description: This file is used to create security group for lambda functions

locals {
  databases_security_group_ids = {
    for app_name, app_input in var.databases_to_refresh : app_name => app_input.DBSecurityGroup
  }
}

resource "aws_security_group" "lambda" {
  description = "Security group attached to the Lambda functions used to rotate secrets"
  name        = "${local.name_cc}Lambda"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "lambda_https_egress" {
  security_group_id = aws_security_group.lambda.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "lambda_mysql_egress" {
  for_each                 = local.databases_security_group_ids
  security_group_id        = aws_security_group.lambda.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
  source_security_group_id = each.value
}

resource "aws_security_group_rule" "mysql_from_lambda" {
  for_each                 = local.databases_security_group_ids
  security_group_id        = each.value
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
  source_security_group_id = aws_security_group.lambda.id
}

output "vpc_security_group_for_lambda" {
  value = aws_security_group.lambda.id
}
