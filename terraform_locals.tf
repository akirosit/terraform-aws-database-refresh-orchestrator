# Version générique du fichier terraform_locals.tf
# Ce fichier remplace terraform_locals.tf

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  current_account_id = data.aws_caller_identity.current.account_id
  current_region     = data.aws_region.current.name

  app_name = "refresh-env-db-${var.app_name}-${var.env_name}"

  name    = local.app_name
  name_cc = replace(title(local.name), "-", "")

  # ARNs génériques pour les ressources
  generic_cluster_arn        = "arn:aws:rds:${local.current_region}:${local.current_account_id}:cluster:*"
  generic_instance_arn       = "arn:aws:rds:${local.current_region}:${local.current_account_id}:db:*"
  generic_security_group_arn = "arn:aws:ec2:${local.current_region}:${local.current_account_id}:security-group/*"
  generic_subnet_group_arn   = "arn:aws:rds:${local.current_region}:${local.current_account_id}:subgrp:*"

  # Utilisation d'ARNs génériques au lieu de ressources spécifiques
  source_cluster_arn                  = [local.generic_cluster_arn]
  source_cluster_arn_wildcard         = ["${local.generic_cluster_arn}-*"]
  source_cluster_security_group_ids   = []
  source_cluster_security_group_arn   = [local.generic_security_group_arn]
  source_cluster_db_subnet_group_name = "generic-subnet-group"
  source_cluster_db_subnet_group_arn  = [local.generic_subnet_group_arn]
  source_cluster_parameter_group      = "generic-parameter-group"
  source_instance_parameter_group     = ["generic-instance-parameter-group"]

  cluster_arn                     = [local.generic_cluster_arn]
  cluster_arn_wildcard            = ["${local.generic_cluster_arn}-*"]
  cluster_parameter_group         = "generic-parameter-group"
  cluster_security_group_ids      = []
  cluster_security_group_arn      = [local.generic_security_group_arn]
  cluster_db_subnet_group_name    = ["generic-subnet-group"]
  cluster_db_subnet_group_arn     = [local.generic_subnet_group_arn]
  cluster_master_user_secret_arn  = ""
  db_instance_class               = "db.serverless"
  instance_databases              = ["generic-instance"]
  instance_databases_arn          = [local.generic_instance_arn]
  instance_databases_arn_wildcard = ["${local.generic_instance_arn}-*"]
  instance_parameter_group        = ["generic-instance-parameter-group"]

  # Bucket S3
  refresh_bucket_id = var.s3_bucket_name == null ? (
    var.create_s3_bucket ? aws_s3_bucket.refresh_bucket[0].id : null
  ) : var.s3_bucket_name

  # Préfixes pour les scripts SQL
  post_sql_scripts_bucket_prefix = "sql-scripts/${local.current_region}/generic"

  # SNS Topic ARN
  sns_topic_arn = var.sns_topic_arn == null ? (
    aws_sns_topic.refresh_env[0].arn
  ) : var.sns_topic_arn
}
