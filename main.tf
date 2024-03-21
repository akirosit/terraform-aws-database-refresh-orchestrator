# This file is used to create step function and associated input json files

locals {
  step_function_input = {
    for app_name, app_input in var.databases_to_refresh : app_name => {
      AppName                  = app_name
      SourceCluster            = app_input.SourceCluster
      Cluster                  = app_input.Cluster
      ClusterArn               = app_input.ClusterArn
      ClusterInstance          = app_input.ClusterInstance
      ClusterInstanceArn       = app_input.ClusterInstanceArn
      ParameterGroup           = app_input.ParameterGroup
      DBSubnetGroup            = app_input.DBSubnetGroup
      DBSecurityGroup          = app_input.DBSecurityGroup
      DbInstanceClass          = app_input.DbInstanceClass
      KmsKeyId                 = app_input.KmsKeyId
      MasterUserSecretKmsKeyId = app_input.KmsKeyId
      RefreshBucket            = local.refresh_bucket_id
      RefreshBucketPrefix      = local.post_sql_scripts_bucket_prefix
      DynamoDBTable            = aws_dynamodb_table.dynamodbTable.name
      SnsTopicArn              = local.sns_topic_arn
    }
  }
  lambdas_arn = { for lambda_name, lambda in aws_lambda_function.functions :
    lambda_name => lambda.arn
  }
}


resource "aws_sfn_state_machine" "refresh_env" {
  name       = local.name_cc
  role_arn   = aws_iam_role.step_function.arn
  definition = templatefile("${path.module}/templates/step_function_definition.json", local.lambdas_arn)
}

resource "local_file" "step_function_json_input" {
  for_each = local.step_function_input
  content  = templatefile("${path.module}/templates/step_function_input.json", each.value)
  filename = "${path.module}/templates/${local.current_region}/db-${each.key}.json"
}

resource "aws_s3_object" "step_function_json_input" {
  for_each = var.put_step_function_input_json_files_on_s3 ? local.step_function_input : {}
  bucket   = local.refresh_bucket_id
  key      = "db-json/${local.current_region}/db-${each.key}.json"
  source   = local_file.step_function_json_input[each.key].filename
  etag     = local_file.step_function_json_input[each.key].content_md5
}

resource "aws_s3_object" "step_function_json_input_hash" {
  for_each = var.put_step_function_input_json_files_on_s3 ? local.step_function_input : {}
  bucket   = local.refresh_bucket_id
  key      = "db-json/${local.current_region}/db-${each.key}.json.base64sha256"
  content  = local_file.step_function_json_input[each.key].content_base64sha256
}
