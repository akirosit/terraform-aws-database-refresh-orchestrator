data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  current_account_id = data.aws_caller_identity.current.account_id
  current_region     = data.aws_region.current.name

  app_name = "refresh-env-db-${var.app_name}-${var.env_name}"

  name    = local.app_name
  name_cc = replace(title(local.name), "-", "")
}

data "aws_rds_cluster" "source_cluster" {
  cluster_identifier = var.source_cluster
}

data "aws_db_instance" "source_cluster" {
  for_each               = data.aws_rds_cluster.source_cluster.cluster_members
  db_instance_identifier = each.value
}

data "aws_security_group" "source_cluster" {
  for_each = toset(local.source_cluster_security_group_ids)
  id       = each.key
}

data "aws_db_subnet_group" "source_cluster" {
  name = local.source_cluster_db_subnet_group_name
}

data "aws_rds_cluster" "refresh_cluster" {
  count              = var.refresh_cluster_already_exist ? 1 : 0
  cluster_identifier = var.refresh_cluster
}

data "aws_db_instance" "refresh_cluster" {
  for_each               = var.refresh_cluster_already_exist ? local.instance_databases : toset([])
  db_instance_identifier = each.value
}

data "aws_security_group" "refresh_cluster" {
  for_each = toset(local.cluster_security_group_ids)
  id       = each.key
}

data "aws_db_subnet_group" "refresh_cluster" {
  count = var.refresh_cluster_already_exist ? 1 : 0
  name  = local.cluster_db_subnet_group_name[0]
}

locals {
  source_cluster_arn = [
    data.aws_rds_cluster.source_cluster.arn
  ]
  source_cluster_arn_wildcard = [
    for database_arn in local.source_cluster_arn : "${database_arn}-*"
  ]
  source_cluster_security_group_ids   = data.aws_rds_cluster.source_cluster.vpc_security_group_ids
  source_cluster_security_group_arn   = ["arn:aws:ec2:${local.current_region}:${local.current_account_id}:security-group/sg-*"] #data.aws_security_group.source_cluster[*].arn
  source_cluster_db_subnet_group_name = data.aws_rds_cluster.source_cluster.db_subnet_group_name
  source_cluster_db_subnet_group_arn  = [data.aws_db_subnet_group.source_cluster.arn]
  source_cluster_parameter_group      = data.aws_rds_cluster.source_cluster.db_cluster_parameter_group_name
  source_instance_parameter_group     = element(values(data.aws_db_instance.source_cluster), 0).db_parameter_groups
  cluster_arn = var.refresh_cluster_already_exist ? data.aws_rds_cluster.refresh_cluster[*].arn : [
    "arn:aws:rds:${local.current_region}:${local.current_account_id}:cluster:${var.refresh_cluster}"
  ]
  cluster_arn_wildcard = [
    for database_arn in local.cluster_arn : "${database_arn}-*"
  ]
  cluster_parameter_group        = var.refresh_cluster_already_exist ? data.aws_rds_cluster.refresh_cluster[0].db_cluster_parameter_group_name : local.source_cluster_parameter_group
  cluster_security_group_ids     = var.refresh_cluster_already_exist ? data.aws_rds_cluster.refresh_cluster[0].vpc_security_group_ids : local.source_cluster_security_group_ids
  cluster_security_group_arn     = local.source_cluster_security_group_arn # var.refresh_cluster_already_exist ? data.aws_security_group.refresh_cluster[*].arn : 
  cluster_db_subnet_group_name   = var.refresh_cluster_already_exist ? data.aws_rds_cluster.refresh_cluster[*].db_subnet_group_name : [local.source_cluster_db_subnet_group_name]
  cluster_db_subnet_group_arn    = var.refresh_cluster_already_exist ? data.aws_db_subnet_group.refresh_cluster[*].arn : local.source_cluster_db_subnet_group_arn
  cluster_master_user_secret_arn = var.refresh_cluster_already_exist ? data.aws_rds_cluster.refresh_cluster[0].master_user_secret[0].secret_arn : null
  db_instance_class              = var.refresh_instance_class == null ? data.aws_db_instance.source_cluster[0].db_instance_class : var.refresh_instance_class
  instance_databases             = var.refresh_cluster_already_exist ? data.aws_rds_cluster.refresh_cluster[0].cluster_members : ["${var.refresh_cluster}-1"]
  instance_databases_arn = [
    "arn:aws:rds:${local.current_region}:${local.current_account_id}:db:*"
  ]
  instance_databases_arn_wildcard = [
    for database_arn in local.instance_databases_arn : "${database_arn}-*"
  ]
  instance_parameter_group = var.refresh_cluster_already_exist ? element(values(data.aws_db_instance.refresh_cluster), 0).db_parameter_groups : local.source_instance_parameter_group
}