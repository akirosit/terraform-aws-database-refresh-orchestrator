# Purpose: This file is used to create IAM policy documents for the lambda role and step function role.

# Locals block to store the ARNs of the databases
locals {
  source_cluster_databases_arn = [
    for app_name, app_input in var.databases_to_refresh : app_input.SourceClusterArn
  ]
  source_cluster_databases_arn_wildcard = [
    for database_arn in local.source_cluster_databases_arn : "${database_arn}-*"
  ]
  source_databases_security_group_arn = [
    for app_name, app_input in var.databases_to_refresh : app_input.SourceDBSecurityGroupArn
  ]
  source_databases_subnet_group_arn = [
    for app_name, app_input in var.databases_to_refresh : app_input.SourceDBSubnetGroupArn
  ]
  cluster_databases_arn = [
    for app_name, app_input in var.databases_to_refresh : app_input.ClusterArn
  ]
  cluster_databases_arn_wildcard = [
    for database_arn in local.cluster_databases_arn : "${database_arn}-*"
  ]
  instance_databases_arn = [
    for app_name, app_input in var.databases_to_refresh : app_input.ClusterInstanceArn
  ]
  instance_databases_arn_wildcard = [
    for database_arn in local.instance_databases_arn : "${database_arn}-*"
  ]
  databases_security_group_arn = [
    for app_name, app_input in var.databases_to_refresh : app_input.DBSecurityGroupArn
  ]
  databases_subnet_group_arn = [
    for app_name, app_input in var.databases_to_refresh : app_input.DBSubnetGroupArn
  ]
}

#
# Lambda IAM Policy Document
#
data "aws_iam_policy_document" "lambda_role" {
  statement {
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:CreateGrant",
    ]
    resources = [
      "arn:aws:kms:*:${local.current_account_id}:alias/*",
      "arn:aws:kms:*:${local.current_account_id}:key/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:RotateSecret",
      "secretsmanager:UpdateSecret",
      "secretsmanager:TagResource",
      "secretsmanager:CreateSecret"
    ]
    resources = [
      "arn:aws:secretsmanager:*:*:secret:*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:ListObjects",
      "s3:DeleteObject",
      "s3:PutObject",
      "s3:GetObject"
    ]
    resources = [
      aws_s3_bucket.refresh_bucket.arn,
      "${aws_s3_bucket.refresh_bucket.arn}/*"
    ]
  }

}

#
# Step Function IAM Policy Document
#
data "aws_iam_policy_document" "assume_from_step_functions" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "step_function_role" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "lambda:InvokeAsync"
    ]
    resources = [for lambda in aws_lambda_function.functions : lambda.arn]
  }
  statement {
    effect = "Allow"
    actions = [
      "states:StartExecution"
    ]
    resources = [
      aws_sfn_state_machine.refresh_env.arn,
      aws_sfn_state_machine.refresh_env_new.arn
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "rds:DescribeDBInstances",
      "rds:DescribeDBSnapshots",
      "rds:ListTagsForResource",
      "rds:DescribeDBClusterSnapshots",
      "rds:DescribeDBClusters",
      "rds:RestoreDBClusterToPointInTime",
    ]
    resources = concat(
      local.source_cluster_databases_arn,
      local.source_cluster_databases_arn_wildcard,
      local.source_databases_subnet_group_arn,
      local.source_databases_security_group_arn,
      local.cluster_databases_arn,
      local.cluster_databases_arn_wildcard,
      local.instance_databases_arn,
      local.instance_databases_arn_wildcard,
      local.databases_subnet_group_arn,
      local.databases_security_group_arn,
      ["arn:aws:rds:${local.current_region}:${local.current_account_id}:cluster-pg:*"]
    )
  }
  statement {
    effect = "Allow"
    actions = [
      "rds:RestoreDBClusterFromSnapshot",
      "rds:CreateDBInstance",
      "rds:ModifyDBInstance",
      "rds:DeleteDBCluster",
      "rds:DeleteDBInstance",
      "rds:AddTagsToResource",
      "rds:RestoreDBInstanceFromDBSnapshot",
      "rds:ModifyDBCluster",
      "rds:CreateDBInstanceReadReplica",
      "rds:RestoreDBInstanceToPointInTime",
      "rds:StopDBInstance"
    ]
    resources = concat(
      local.cluster_databases_arn,
      local.cluster_databases_arn_wildcard,
      local.instance_databases_arn,
      local.instance_databases_arn_wildcard,
      local.databases_subnet_group_arn,
      local.databases_security_group_arn,
      [
        "arn:aws:rds:${local.current_region}:${local.current_account_id}:cluster-pg:*",
        "arn:aws:rds:${local.current_region}:${local.current_account_id}:pg:*"
      ]
    )
  }
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:PutItem"
    ]
    resources = [aws_dynamodb_table.dynamodbTable.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = [aws_sns_topic.refresh.arn]
  }
}
