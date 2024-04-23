# This file is used to create step function and associated input json files

locals {
  step_function_input = {
    AppName                       = var.app_name
    EnvName                       = var.env_name
    SourceCluster                 = var.source_cluster
    Cluster                       = var.refresh_cluster
    ClusterArn                    = local.cluster_arn
    ClusterInstance               = element(tolist(local.instance_databases), 0)
    ClusterInstanceArn            = local.instance_databases_arn[0]
    ClusterParameterGroup         = local.cluster_parameter_group
    RestoreType                   = var.restore_type
    DeleteOldCluster              = var.delete_old_cluster
    ParameterGroup                = element(tolist(local.instance_parameter_group), 0)
    DBSubnetGroup                 = element(tolist(local.cluster_db_subnet_group_name), 0)
    DBSecurityGroup               = element(tolist(local.cluster_security_group_ids), 1)
    DbInstanceClass               = local.db_instance_class
    Encrypted                     = var.encrypted
    KmsKeyId                      = var.kms_key_id == null ? "" : var.kms_key_id
    MasterUserSecretKmsKeyId      = var.master_user_kms_key_id == null ? aws_kms_key.refresh_secret[0].key_id : var.master_user_kms_key_id
    RefreshBucket                 = local.refresh_bucket_id
    RunSqlScriptsBucket           = var.run_post_sql_scripts
    RefreshBucketPrefix           = local.post_sql_scripts_bucket_prefix
    OldMasterUserSecretArn        = local.cluster_master_user_secret_arn
    RDSRoleArn                    = aws_iam_role.rds.arn
    RunSqlScripts                 = var.run_post_sql_scripts
    RunSqlScriptsOldCluster       = var.run_pre_sql_scripts
    OldDatabaseName               = var.old_database_name
    DatabaseName                  = var.database_name
    RefreshBucketPrefixOldCluster = "${local.post_sql_scripts_bucket_prefix}-old"
    RotateDatabaseUsersSecrets    = var.rotate_database_users_secrets
    RotationLambdaARN             = aws_lambda_function.functions["SecretsManagerRDSMySQLRotationMultiUser"].arn
    DatabaselUsersSecrets         = jsonencode(var.database_users_secrets)
    RenameCluster                 = var.rename_cluster
    DynamoDBTable                 = aws_dynamodb_table.dynamodbTable.name
    SnsTopicArn                   = local.sns_topic_arn
    Tags                          = jsonencode(var.tags)
  }
  lambdas_arn = { for lambda_name, lambda in aws_lambda_function.functions :
    lambda_name => lambda.arn
  }
}

resource "aws_kms_key" "refresh_secret" {
  count       = var.master_user_kms_key_id == null ? 1 : 0
  description = local.name
}

resource "aws_kms_alias" "refresh_secret" {
  count         = var.master_user_kms_key_id == null ? 1 : 0
  name          = "alias/${local.name}"
  target_key_id = aws_kms_key.refresh_secret[0].key_id
}

resource "aws_sfn_state_machine" "refresh_env" {
  name       = local.name_cc
  role_arn   = aws_iam_role.step_function.arn
  definition = templatefile("${path.module}/templates/step_function_definition.json", local.lambdas_arn)
}

resource "local_file" "step_function_json_input" {
  content  = templatefile("${path.module}/templates/step_function_input.json", local.step_function_input)
  filename = "step_function_input/${local.current_region}/db-${var.app_name}-${var.env_name}.json"
}

resource "aws_s3_object" "step_function_json_input" {
  count  = var.put_step_function_input_json_files_on_s3 ? 1 : 0
  bucket = local.refresh_bucket_id
  key    = "db-json/${local.current_region}/db-${var.app_name}-${var.env_name}.json"
  source = local_file.step_function_json_input.filename
  etag   = local_file.step_function_json_input.content_md5
}

resource "aws_s3_object" "step_function_json_input_hash" {
  count   = var.put_step_function_input_json_files_on_s3 ? 1 : 0
  bucket  = local.refresh_bucket_id
  key     = "db-json/${local.current_region}/db-${var.app_name}-${var.env_name}.json.base64sha256"
  content = local_file.step_function_json_input.content_base64sha256
}
