# Purpose: This file is used to create IAM policy documents for the lambda role and step function role.

#
# S3 Policy Document
#
data "aws_iam_policy_document" "assume_from_rds" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }
}
data "aws_iam_policy_document" "s3" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:AbortMultipartUpload",
      "s3:ListBucket",
      "s3:DeleteObject",
      "s3:GetObjectVersion",
      "s3:ListMultipartUploadParts"
    ]
    resources = [
      "arn:aws:s3:::${local.refresh_bucket_id}",
      "arn:aws:s3:::${local.refresh_bucket_id}/*"
    ]
  }
}
#
# Lambda IAM Policy Document
#
data "aws_iam_policy_document" "assume_from_lambda" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
data "aws_iam_policy_document" "lambda_role" {
  statement {
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:CreateGrant",
      "kms:ListGrants"
    ]
    resources = [
      "arn:aws:kms:*:${local.current_account_id}:alias/*",
      "arn:aws:kms:*:${local.current_account_id}:key/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:ListKeys",
      "kms:ListAliases"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:RotateSecret",
      "secretsmanager:UpdateSecret",
      "secretsmanager:TagResource",
      "secretsmanager:CreateSecret",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecretVersionStage",
      "secretsmanager:GetRandomPassword"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "rds:DescribeDBInstances",
      "rds:DescribeDBClusters",
    ]
    resources = concat(
      local.source_cluster_arn,
      local.source_cluster_arn_wildcard,
      local.cluster_arn,
      local.cluster_arn_wildcard,
      local.instance_databases_arn,
      local.instance_databases_arn_wildcard
    )
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

data "aws_iam_policy_document" "step_function_assume_eks_role" {
  count = var.eks_role_arn != "" ? 1 : 0
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = [var.eks_role_arn]
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
    resources = [aws_sfn_state_machine.refresh_env.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole",
    ]
    resources = [aws_iam_role.rds.arn]
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
      "rds:RestoreDBClusterFromSnapshot"
    ]
    resources = concat(
      local.source_cluster_arn,
      local.source_cluster_arn_wildcard,
      local.source_cluster_db_subnet_group_arn,
      local.source_cluster_security_group_arn,
      local.cluster_arn,
      local.cluster_arn_wildcard,
      local.instance_databases_arn,
      local.instance_databases_arn_wildcard,
      local.cluster_db_subnet_group_arn,
      local.cluster_security_group_arn,
      [
        "arn:aws:rds:${local.current_region}:*:cluster:*",
        "arn:aws:rds:${local.current_region}:${local.current_account_id}:cluster-pg:*",
        "arn:aws:rds:${local.current_region}:${local.current_account_id}:cluster-snapshot:rds:*",
      ]
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
      "rds:StopDBCluster",
      "rds:StopDBInstance",
      "rds:AddRoleToDBCluster",
      "rds:ModifyDBClusterParameterGroup",
    ]
    resources = concat(
      local.cluster_arn,
      local.cluster_arn_wildcard,
      local.instance_databases_arn,
      local.instance_databases_arn_wildcard,
      local.cluster_db_subnet_group_arn,
      local.cluster_security_group_arn,
      [
        "arn:aws:rds:${local.current_region}:${local.current_account_id}:cluster-pg:*",
        "arn:aws:rds:${local.current_region}:${local.current_account_id}:pg:*"
      ]
    )
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:CreateGrant",
      "kms:ListGrants"
    ]
    resources = [
      "arn:aws:kms:*:${local.current_account_id}:alias/*",
      "arn:aws:kms:*:${local.current_account_id}:key/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:ListKeys",
      "kms:ListAliases"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:RotateSecret",
      "secretsmanager:UpdateSecret",
      "secretsmanager:TagResource",
      "secretsmanager:CreateSecret",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecretVersionStage",
      "secretsmanager:GetRandomPassword"
    ]
    resources = [
      "*"
    ]
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
    resources = [local.sns_topic_arn]
  }
  statement {
    effect    = "Allow"
    actions   = ["tag:TagResources"]
    resources = ["*"]
  }
}
